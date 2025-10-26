// com/newsportal/i18n/GoogleTranslateService.java
package com.newsportal.i18n;

import com.google.gson.*;
import okhttp3.*;

import java.nio.charset.StandardCharsets;
import java.util.ArrayList;
import java.util.List;

public class GoogleTranslateService implements TranslationService {
  private static final String ENDPOINT = "https://translation.googleapis.com/language/translate/v2";
  private final OkHttpClient http = new OkHttpClient();
  private final String apiKey;

  public GoogleTranslateService(String apiKey) {
    this.apiKey = apiKey;
  }

  @Override
  public String translateViToEn(String text, boolean html) throws Exception {
    if (text == null || text.isBlank()) return text;

    // Google v2 giới hạn ~ 30k bytes/lần gọi. Cắt đoạn ~4k ký tự để an toàn.
    List<String> chunks = chunk(text, 4000);
    StringBuilder out = new StringBuilder();

    for (String c : chunks) {
      HttpUrl url = HttpUrl.parse(ENDPOINT).newBuilder()
          .addQueryParameter("key", apiKey).build();

      FormBody.Builder fb = new FormBody.Builder(StandardCharsets.UTF_8)
          .add("q", c)
          .add("source", "vi")
          .add("target", "en")
          .add("format", html ? "html" : "text");

      Request req = new Request.Builder().url(url).post(fb.build()).build();
      try (Response resp = http.newCall(req).execute()) {
        if (!resp.isSuccessful()) throw new RuntimeException("Translate API HTTP " + resp.code());
        String json = resp.body().string();
        JsonObject root = JsonParser.parseString(json).getAsJsonObject();
        String translated = root.getAsJsonObject("data")
            .getAsJsonArray("translations").get(0).getAsJsonObject()
            .get("translatedText").getAsString();
        out.append(translated);
      }
    }
    return out.toString();
  }

  private static List<String> chunk(String s, int max) {
    List<String> res = new ArrayList<>();
    int i=0;
    while (i < s.length()) {
      int j = Math.min(s.length(), i + max);
      res.add(s.substring(i, j));
      i = j;
    }
    return res;
  }
}
