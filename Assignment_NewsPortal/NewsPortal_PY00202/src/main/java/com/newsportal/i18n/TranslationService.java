// com/newsportal/i18n/TranslationService.java
package com.newsportal.i18n;

public interface TranslationService {
	/** Dịch VI -> EN. Nếu html=true, giữ nguyên markup. */
	String translateViToEn(String text, boolean html) throws Exception;
}