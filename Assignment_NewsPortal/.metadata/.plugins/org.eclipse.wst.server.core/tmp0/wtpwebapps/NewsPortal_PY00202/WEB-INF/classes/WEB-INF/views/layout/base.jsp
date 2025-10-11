<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core"%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><c:out value="${pageTitle != null ? pageTitle : 'NewsPortal'}" /></title>
    
    <!-- Base CSS -->
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/base.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/components.css">
    
    <!-- Page specific CSS -->
    <c:if test="${not empty pageCSS}">
        <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/${pageCSS}">
    </c:if>
    
    <!-- Additional head content -->
    <c:if test="${not empty additionalHead}">
        ${additionalHead}
    </c:if>
</head>
<body class="${bodyClass != null ? bodyClass : ''}">
    <!-- Page content will be inserted here -->
</body>
</html>