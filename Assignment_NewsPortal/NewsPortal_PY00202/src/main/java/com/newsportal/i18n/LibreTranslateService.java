package com.newsportal.i18n;

import com.google.gson.*;
import okhttp3.*;

import java.nio.charset.StandardCharsets;
import java.time.Duration;
import java.util.ArrayList;
import java.util.List;

/**
 * Dịch VI -> EN qua LibreTranslate (miễn phí, không cần billing).
 * - Mặc định endpoint: https://libretranslate.de/translate
 * - Có thể đổi qua ENV: LT_ENDPOINT  (ví dụ: https://libretranslate.com/translate)
 * - Nếu server yêu cầu API key: đặt ENV LT_API_KEY
 */
public class LibreTranslateService implements TranslationService {

  private static final MediaType FORM = MediaType.parse("application/x-www-form-urlencoded; charset=utf-8");

  private final OkHttpClient http;
  private final String endpoint;
  private final String apiKey; // phần lớn public endpoint không cần

  public LibreTranslateService() {
    this(System.getenv().getOrDefault("LT_ENDPOINT", "https://libretranslate.de/translate"),
         System.getenv("LT_API_KEY"));
  }

  public LibreTranslateService(String endpoint, String apiKey) {
    this.http = new OkHttpClient.Builder()
        .callTimeout(Duration.ofSeconds(60))
        .connectTimeout(Duration.ofSeconds(15))
        .readTimeout(Duration.ofSeconds(60))
        .build();
    this.endpoint = endpoint;
    this.apiKey = apiKey;
  }

  @Override
  public String translateViToEn(String text, boolean html) throws Exception {
    if (text == null || text.isBlank()) return text;

    // Cắt nhỏ để tránh giới hạn kích thước request (an toàn ~4000 ký tự).
    List<String> chunks = chunk(text, 4000);
    StringBuilder out = new StringBuilder();

    for (String c : chunks) {
      FormBody.Builder fb = new FormBody.Builder(StandardCharsets.UTF_8)
          .add("q", c)
          .add("source", "vi")
          .add("target", "en")
          .add("format", html ? "html" : "text");
      if (apiKey != null && !apiKey.isBlank()) fb.add("api_key", apiKey);

      Request req = new Request.Builder()
          .url(endpoint)
          .post(fb.build())
          .build();

      try (Response resp = http.newCall(req).execute()) {
    	  String body = safeBody(resp); // đọc body một lần
    	  if (!resp.isSuccessful()) {
    	    throw new RuntimeException("LibreTranslate HTTP " + resp.code() + " body: " + body);
    	  }
    	  JsonObject root = JsonParser.parseString(body).getAsJsonObject();
    	  String translated = root.get("translatedText").getAsString();
    	  out.append(translated);
    	}

    }
    return out.toString();
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

  private static String safeBody(Response r) {
    try { return r.body() == null ? "" : r.body().string(); }
    catch (Exception ignore) { return ""; }
  }
}
