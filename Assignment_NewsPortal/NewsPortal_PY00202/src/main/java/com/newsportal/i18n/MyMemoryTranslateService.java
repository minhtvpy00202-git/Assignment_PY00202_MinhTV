package com.newsportal.i18n;

import com.google.gson.*;
import okhttp3.*;
import org.jsoup.Jsoup;
import org.jsoup.nodes.*;
import org.jsoup.select.NodeTraversor;
import org.jsoup.select.NodeVisitor;

import java.time.Duration;
import java.util.ArrayList;
import java.util.List;

public class MyMemoryTranslateService implements TranslationService {

	private static final HttpUrl BASE = HttpUrl.parse("https://api.mymemory.translated.net/get");
	private final OkHttpClient http = new OkHttpClient.Builder().callTimeout(Duration.ofSeconds(60))
			.connectTimeout(Duration.ofSeconds(15)).readTimeout(Duration.ofSeconds(60)).build();

	@Override
	public String translateViToEn(String text, boolean html) throws Exception {
		if (text == null || text.isBlank())
			return text;
		return html ? translateHtmlPreserveMarkup(text) : translatePlain(text);
	}

	/* ---------- TEXT ---------- */

	private String translatePlain(String src) throws Exception {
		List<String> chunks = chunk(src, 450);
		StringBuilder out = new StringBuilder();
		for (String c : chunks)
			out.append(translateChunk(c));
		return out.toString();
	}

	/* ---------- HTML (giữ nguyên markup) ---------- */

	private String translateHtmlPreserveMarkup(String html) throws Exception {
		// Dùng <body> để lấy innerHTML sau khi dịch
		Document doc = Jsoup.parseBodyFragment(html);

		// Duyệt toàn bộ cây; chỉ dịch TextNode và một vài thuộc tính
		NodeTraversor.traverse(new NodeVisitor() {
			@Override
			public void head(Node node, int depth) {
				try {
					if (node instanceof TextNode tn) {
						String t = tn.getWholeText();
						if (t != null && !t.trim().isEmpty()) {
							tn.text(translatePlain(t));
						}
					} else if (node instanceof Element el) {
						// Dịch các thuộc tính mô tả
						translateAttrIfPresent(el, "title");
						translateAttrIfPresent(el, "alt");
						// KHÔNG động vào src/href
					}
				} catch (Exception e) {
					// Không ném lỗi để khỏi mất toàn bộ bài
				}
			}

			@Override
			public void tail(Node node, int depth) {
			}
		}, doc.body());

		// Trả lại phần inner HTML (không bọc thêm <html><body>)
		return doc.body().html();
	}

	private void translateAttrIfPresent(Element el, String attr) throws Exception {
		if (!el.hasAttr(attr))
			return;
		String v = el.attr(attr);
		if (v != null && !v.trim().isEmpty()) {
			el.attr(attr, translatePlain(v));
		}
	}

	/* ---------- Gọi MyMemory ---------- */

	private String translateChunk(String c) throws Exception {
		HttpUrl url = BASE.newBuilder().addQueryParameter("q", c) // để OkHttp tự encode
				.addQueryParameter("langpair", "vi|en").build();

		Request req = new Request.Builder().url(url).get().build();

		for (int tries = 1;; tries++) {
			try (Response resp = http.newCall(req).execute()) {
				if (!resp.isSuccessful()) {
					if ((resp.code() == 429 || resp.code() >= 500) && tries < 3) {
						Thread.sleep(600L * tries);
						continue;
					}
					throw new RuntimeException("MyMemory HTTP " + resp.code() + ": " + safeBody(resp));
				}
				String json = resp.body().string();
				JsonObject root = JsonParser.parseString(json).getAsJsonObject();
				if (root.has("responseStatus") && root.get("responseStatus").getAsInt() != 200) {
					String details = root.has("responseDetails") ? root.get("responseDetails").getAsString() : "";
					throw new RuntimeException("MyMemory error: " + details);
				}
				JsonObject data = root.getAsJsonObject("responseData");
				if (data == null || !data.has("translatedText"))
					throw new RuntimeException("Unexpected JSON: " + json);
				return data.get("translatedText").getAsString();
			}
		}
	}

	private static String safeBody(Response r) {
		try {
			return r.body() == null ? "" : r.body().string();
		} catch (Exception ignore) {
			return "";
		}
	}

	private static List<String> chunk(String s, int max) {
		List<String> res = new ArrayList<>();
		int i = 0;
		while (i < s.length()) {
			int j = Math.min(s.length(), i + max);
			res.add(s.substring(i, j));
			i = j;
		}
		return res;
	}
}
