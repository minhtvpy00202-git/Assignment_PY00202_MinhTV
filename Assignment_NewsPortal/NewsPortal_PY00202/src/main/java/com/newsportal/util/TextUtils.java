// com/newsportal/util/TextUtils.java
package com.newsportal.util;

public class TextUtils {
  public static String stripHtml(String html) {
    if (html == null) return null;
    return html.replaceAll("<[^>]*>", " ").replaceAll("\\s+", " ").trim();
  }
  public static String ellipsize(String s, int max) {
    if (s == null) return null;
    s = s.trim();
    return s.length() <= max ? s : s.substring(0, Math.max(0, max-1)).trim() + "…";
  }
}
