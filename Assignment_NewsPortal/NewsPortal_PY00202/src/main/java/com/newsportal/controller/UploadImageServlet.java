package com.newsportal.controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.*;
import java.nio.file.*;
import java.util.*;

@WebServlet("/upload-image")
@MultipartConfig(maxFileSize = 10*1024*1024, maxRequestSize = 50*1024*1024)
public class UploadImageServlet extends HttpServlet {
  @Override protected void doPost(HttpServletRequest req, HttpServletResponse resp)
      throws ServletException, IOException {
    Part file = req.getPart("upload");                 // CKEditor 5 gửi field name = "upload"
    if (file == null || file.getSize() == 0) {
      sendJson(resp, 400, "{\"error\":{\"message\":\"No file\"}}");
      return;
    }

    String submitted = Paths.get(file.getSubmittedFileName()).getFileName().toString();
    String ext = submitted.contains(".") ? submitted.substring(submitted.lastIndexOf('.')+1).toLowerCase() : "";
    String mime = file.getContentType() == null ? "" : file.getContentType().toLowerCase();
    if (!mime.startsWith("image/")) {
      sendJson(resp, 400, "{\"error\":{\"message\":\"Not an image\"}}");
      return;
    }

    String newName = System.currentTimeMillis()+"_"+UUID.randomUUID().toString().substring(0,8)+"."+ext;
    Path dir = Path.of(getServletContext().getRealPath("/assets/uploads"));
    Files.createDirectories(dir);
    try (InputStream in = file.getInputStream()) {
      Files.copy(in, dir.resolve(newName), StandardCopyOption.REPLACE_EXISTING);
    }

    // URL ảnh có contextPath để trình duyệt truy cập được
    String url = req.getContextPath()+"/assets/uploads/"+newName;

    // CKEditor 5 simpleUpload chấp nhận 3 format; trả "url" là đủ,
    // nhưng để an toàn ta trả cả 3:
    String json = "{"
        + "\"url\":\""+url+"\","
        + "\"urls\":{\"default\":\""+url+"\"},"
        + "\"uploaded\":true"
        + "}";
    sendJson(resp, 201, json);
  }

  private static void sendJson(HttpServletResponse resp, int code, String body) throws IOException {
    resp.setStatus(code);
    resp.setContentType("application/json; charset=UTF-8");
    resp.getWriter().write(body);
  }
}

