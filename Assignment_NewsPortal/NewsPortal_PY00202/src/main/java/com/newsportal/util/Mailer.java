package com.newsportal.util;

import jakarta.mail.*;
import jakarta.mail.internet.*;
import java.util.*;

public class Mailer {

    // TODO: chuyển sang đọc từ env/context-param khi đưa vào production
    private static final String SMTP_HOST = "smtp.gmail.com";
    private static final int    SMTP_PORT = 587;
    private static final String SMTP_USER = "minhtvpy00202@gmail.com";
    private static final String SMTP_PASS = "kjek wnui kjiy cejh";
    private static final String FROM_NAME = "NewsPortal";

    private static Session session() {
        Properties p = new Properties();
        p.put("mail.smtp.auth", "true");
        p.put("mail.smtp.starttls.enable", "true");
        p.put("mail.smtp.host", SMTP_HOST);
        p.put("mail.smtp.port", String.valueOf(SMTP_PORT));

        return Session.getInstance(p, new Authenticator() {
            @Override protected PasswordAuthentication getPasswordAuthentication() {
                return new PasswordAuthentication(SMTP_USER, SMTP_PASS);
            }
        });
    }

    public static void sendBcc(List<String> recipients, String subject, String htmlBody) throws Exception {
        if (recipients == null || recipients.isEmpty()) return;

        // Chia lô để tránh giới hạn số người nhận/tiêu đề dài
        final int BATCH = 50;
        for (int i = 0; i < recipients.size(); i += BATCH) {
            List<String> batch = recipients.subList(i, Math.min(i + BATCH, recipients.size()));

            Message msg = new MimeMessage(session());
            msg.setFrom(new InternetAddress(SMTP_USER, FROM_NAME, java.nio.charset.StandardCharsets.UTF_8.name()));
            msg.setSubject(subject);
            msg.setHeader("Content-Transfer-Encoding", "quoted-printable");

            // BCC
            for (String r : batch) {
                msg.addRecipient(Message.RecipientType.BCC, new InternetAddress(r));
            }

            msg.setContent(htmlBody, "text/html; charset=UTF-8");
            Transport.send(msg);
        }
    }
}
