// src/main/java/com/newsportal/filter/I18nFilter.java
package com.newsportal.filter;

import jakarta.servlet.*;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.HttpServletRequest;
import java.io.IOException;

@WebFilter("/*")
public class I18nFilter implements Filter {
  @Override
  public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
      throws IOException, ServletException {
    HttpServletRequest req = (HttpServletRequest) request;
    String lang = req.getParameter("lang");
    if (lang != null && !lang.isBlank()) {
      req.getSession().setAttribute("lang", lang); // "vi" hoặc "en"
    }
    chain.doFilter(request, response);
  }
}
