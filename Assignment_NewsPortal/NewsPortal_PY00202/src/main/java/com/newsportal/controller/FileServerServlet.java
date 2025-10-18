package com.newsportal.controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.*;
import java.nio.file.*;

@WebServlet("/uploads/*")
public class FileServerServlet extends HttpServlet {
    // THƯ MỤC THẬT NƠI ẢNH ĐƯỢC LƯU
    private static final Path BASE = Paths.get(
        "C:/FPOLY/JAVA3/Assignment_PY00202_MinhTV/Assignment_NewsPortal/newsportal-uploads"
    );

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws IOException, ServletException {

        String rel = req.getPathInfo();      // ví dụ: "/1760752488347_ac9e45b1.jpg"
        if (rel == null || rel.contains("..")) { resp.sendError(400); return; }

        Path file = BASE.resolve(rel.substring(1)).normalize();
        if (!Files.exists(file) || Files.isDirectory(file)) { resp.sendError(404); return; }

        String mime = Files.probeContentType(file);
        if (mime != null) resp.setContentType(mime);
        resp.setHeader("Cache-Control", "public, max-age=31536000");

        try (OutputStream out = resp.getOutputStream()) {
            Files.copy(file, out);
        }
    }
}
