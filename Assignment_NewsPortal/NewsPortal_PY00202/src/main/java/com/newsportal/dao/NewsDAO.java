package com.newsportal.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.sql.Timestamp;
import java.sql.Types;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;

import com.newsportal.model.News;
import com.newsportal.util.DB;

public class NewsDAO {
	private static final String ND = "ISNULL(IsDelete,0)=0";
	private static final String ND_CAT = "EXISTS (SELECT 1 FROM Categories c WHERE c.Id = News.CategoryId AND ISNULL(c.IsDelete,0)=0)";

	/* ====================== CREATE ====================== */
	/** Tạo bài viết mới. Trả về Id vừa tạo. */
	public int create(News n) throws Exception {
		String sql = """
				INSERT INTO News
				  (Title, Content, Image, PostedDate, Author, ViewCount, CategoryId, Home, Approved, ReporterId, isDelete)
				VALUES
				  (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, 0)
				""";
		try (Connection cn = DB.getConnection();
				PreparedStatement ps = cn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {

			ps.setString(1, n.getTitle());
			ps.setString(2, n.getContent());
			ps.setString(3, n.getImage());
			ps.setTimestamp(4, Timestamp.valueOf(n.getPostedDate())); // LocalDateTime -> SQL
			ps.setString(5, n.getAuthor());
			ps.setInt(6, n.getViewCount()); // thường = 0 khi tạo
			ps.setInt(7, n.getCategoryId());
			ps.setBoolean(8, n.isHome());
			ps.setBoolean(9, n.isApproved());
			if (n.getReporterId() == null)
				ps.setNull(10, Types.INTEGER);
			else
				ps.setInt(10, n.getReporterId());

			ps.executeUpdate();
			try (ResultSet rs = ps.getGeneratedKeys()) {
				return rs.next() ? rs.getInt(1) : 0;
			}
		}
	}

	// ===== Public APIs dùng cho HomeServlet =====

	/** Lấy danh sách bài đặt Trang nhất (Home = 1), đã duyệt, mới nhất trước. */
	public List<News> findHome(int limit) throws Exception {
		String sql = "SELECT Id, Title, [Content], [Image], PostedDate, Author, ViewCount,"
				+ "       CategoryId, [Home], Approved, ReporterId " + "FROM News " + "WHERE " + ND
				+ " AND Approved=1 AND [Home]=1 " + "ORDER BY PostedDate DESC " + "OFFSET 0 ROWS FETCH NEXT "
				+ Math.max(0, limit) + " ROWS ONLY";
		try (Connection cn = DB.getConnection();
				PreparedStatement ps = cn.prepareStatement(sql);
				ResultSet rs = ps.executeQuery()) {
			List<News> list = new ArrayList<>();
			while (rs.next())
				list.add(map(rs));
			return list;
		}
	}

	/** Top N hot theo ViewCount giảm dần, chỉ lấy bài đã duyệt. */
	public List<News> findTopHot(int limit) throws Exception {
		String sql = "SELECT Id, Title, [Content], [Image], PostedDate, Author, ViewCount,"
				+ "       CategoryId, [Home], Approved, ReporterId " + "FROM News " + "WHERE " + ND + " AND Approved=1 "
				+ "ORDER BY ViewCount DESC, PostedDate DESC " + "OFFSET 0 ROWS FETCH NEXT " + Math.max(0, limit)
				+ " ROWS ONLY";
		try (Connection cn = DB.getConnection();
				PreparedStatement ps = cn.prepareStatement(sql);
				ResultSet rs = ps.executeQuery()) {
			List<News> list = new ArrayList<>();
			while (rs.next())
				list.add(map(rs));
			return list;
		}
	}

	/** Top N mới theo PostedDate, chỉ lấy bài đã duyệt. */
	public List<News> findTopNew(int limit) throws Exception {
		String sql = "SELECT Id, Title, [Content], [Image], PostedDate, Author, ViewCount,"
				+ "       CategoryId, [Home], Approved, ReporterId " + "FROM News " + "WHERE " + ND + " AND Approved=1 "
				+ "ORDER BY PostedDate DESC " + "OFFSET 0 ROWS FETCH NEXT " + Math.max(0, limit) + " ROWS ONLY";
		try (Connection cn = DB.getConnection();
				PreparedStatement ps = cn.prepareStatement(sql);
				ResultSet rs = ps.executeQuery()) {
			List<News> list = new ArrayList<>();
			while (rs.next())
				list.add(map(rs));
			return list;
		}
	}

	/** Lấy 1 bài theo Id (có thể dùng cả khi chưa duyệt, tuỳ luồng). */
	public News findById(int id) throws Exception {
		String sql = "SELECT Id, Title, [Content], [Image], PostedDate, Author, ViewCount,"
				+ "       CategoryId, [Home], Approved, ReporterId " + "FROM News WHERE " + ND + " AND Id=?";
		try (Connection cn = DB.getConnection(); PreparedStatement ps = cn.prepareStatement(sql)) {
			ps.setInt(1, id);
			try (ResultSet rs = ps.executeQuery()) {
				return rs.next() ? map(rs) : null;
			}
		}
	}

	// ===== (Tuỳ chọn) Hữu ích cho phần khác =====

	/** Tăng view 1 đơn vị (gọi trong NewsDetailServlet). */
	public void increaseView(int id) throws Exception {
		try (Connection cn = DB.getConnection();
				PreparedStatement ps = cn.prepareStatement("UPDATE News SET ViewCount = ViewCount + 1 WHERE Id = ?")) {
			ps.setInt(1, id);
			ps.executeUpdate();
		}
	}

	/** Truy vấn theo Category (đã duyệt), có phân trang. */
	public List<News> findByCategory(int categoryId, int offset, int pageSize) throws Exception {
		String sql = "SELECT Id, Title, [Content], [Image], PostedDate, Author, ViewCount,"
				+ "       CategoryId, [Home], Approved, ReporterId " + "FROM News WHERE " + ND
				+ " AND Approved=1 AND CategoryId=? " + "ORDER BY PostedDate DESC "
				+ "OFFSET ? ROWS FETCH NEXT ? ROWS ONLY";
		try (Connection cn = DB.getConnection(); PreparedStatement ps = cn.prepareStatement(sql)) {
			ps.setInt(1, categoryId);
			ps.setInt(2, Math.max(0, offset));
			ps.setInt(3, Math.max(0, pageSize));
			try (ResultSet rs = ps.executeQuery()) {
				List<News> list = new ArrayList<>();
				while (rs.next())
					list.add(map(rs));
				return list;
			}
		}
	}

	/** Tìm kiếm tiêu đề/nội dung (đã duyệt). */
	public List<News> search(String keyword, int limit) throws Exception {
		String kw = (keyword == null ? "" : keyword.trim());

		String sql = "SELECT n.Id, n.Title, n.[Content], n.[Image], n.PostedDate, n.Author, n.ViewCount, "
				+ "       n.CategoryId, n.[Home], n.Approved, n.ReporterId " + "FROM News n "
				+ "JOIN Categories c ON c.Id = n.CategoryId AND ISNULL(c.IsDelete,0)=0 "
				+ "LEFT JOIN Users u ON u.Id = n.ReporterId " + "WHERE " + ND.replace("IsDelete", "n.IsDelete") + " "
				+ "  AND n.Approved = 1 " + "  AND (u.Id IS NULL OR ISNULL(u.IsDelete,0)=0) " + // loại bài của tác giả
																								// đã xóa mềm
				"  AND (n.Title LIKE ? OR n.[Content] LIKE ?) " + "ORDER BY n.PostedDate DESC "
				+ "OFFSET 0 ROWS FETCH NEXT ? ROWS ONLY";

		try (Connection cn = DB.getConnection(); PreparedStatement ps = cn.prepareStatement(sql)) {

			String like = "%" + kw + "%";
			ps.setString(1, like);
			ps.setString(2, like);
			ps.setInt(3, Math.max(0, limit));

			try (ResultSet rs = ps.executeQuery()) {
				List<News> list = new ArrayList<>();
				while (rs.next())
					list.add(map(rs));
				return list;
			}
		}
	}

	// các bài đã duyệt theo chuyên mục, mới nhất trước
	public List<News> findByCategory(int categoryId) throws Exception {
		String sql = "SELECT n.Id, n.Title, n.Content, n.Image, n.PostedDate, n.Author, n.ViewCount, "
				+ "       n.CategoryId, n.Home, n.Approved, n.ReporterId " + "FROM News n "
				+ "LEFT JOIN Users u ON u.Id = n.ReporterId " + "WHERE " + ND.replace("IsDelete", "n.IsDelete") + " "
				+ "  AND n.Approved = 1 " + "  AND n.CategoryId = ? "
				+ "  AND (u.Id IS NULL OR ISNULL(u.IsDelete,0)=0) " + "ORDER BY n.PostedDate DESC";

		try (Connection cn = DB.getConnection(); PreparedStatement ps = cn.prepareStatement(sql)) {
			ps.setInt(1, categoryId);
			try (ResultSet rs = ps.executeQuery()) {
				List<News> list = new ArrayList<>();
				while (rs.next())
					list.add(map(rs));
				return list;
			}
		}
	}

	/* ====================== UPDATE ====================== */
	/** Cập nhật toàn bộ trường (trừ Id). */
	public void update(News n) throws Exception {
		String sql = """
				UPDATE News
				   SET Title=?, Content=?, Image=?, PostedDate=?, Author=?,
				       ViewCount=?, CategoryId=?, Home=?, Approved=?, ReporterId=?
				 WHERE Id=?
				""";
		try (Connection cn = DB.getConnection(); PreparedStatement ps = cn.prepareStatement(sql)) {

			ps.setString(1, n.getTitle());
			ps.setString(2, n.getContent());
			ps.setString(3, n.getImage());
			ps.setTimestamp(4, Timestamp.valueOf(n.getPostedDate()));
			ps.setString(5, n.getAuthor());
			ps.setInt(6, n.getViewCount());
			ps.setInt(7, n.getCategoryId());
			ps.setBoolean(8, n.isHome());
			ps.setBoolean(9, n.isApproved());
			if (n.getReporterId() == null)
				ps.setNull(10, Types.INTEGER);
			else
				ps.setInt(10, n.getReporterId());
			ps.setInt(11, n.getId());

			ps.executeUpdate();
		}
	}

	/* ====================== DELETE ====================== */
	public boolean delete(int id) throws Exception {
		try (Connection cn = DB.getConnection();
				PreparedStatement ps = cn.prepareStatement("UPDATE News SET IsDelete=1 WHERE Id=?")) {
			ps.setInt(1, id);
			return ps.executeUpdate() > 0;
		}
	}

	/* Khôi phục xóa mềm */
	public boolean restore(int id) throws Exception {
		try (Connection cn = DB.getConnection();
				PreparedStatement ps = cn.prepareStatement("UPDATE News SET IsDelete=0 WHERE Id=?")) {
			ps.setInt(1, id);
			return ps.executeUpdate() > 0;
		}
	}

	/** Lấy tất cả bài viết, mới nhất trước. */
	public List<News> findAll() throws Exception {
		String sql = "SELECT Id, Title, Content, Image, PostedDate, Author, ViewCount, "
				+ "       CategoryId, Home, Approved, ReporterId " + "FROM News " + "WHERE " + ND + " "
				+ "ORDER BY PostedDate DESC";
		try (Connection cn = DB.getConnection();
				PreparedStatement ps = cn.prepareStatement(sql);
				ResultSet rs = ps.executeQuery()) {
			List<News> list = new ArrayList<>();
			while (rs.next())
				list.add(map(rs));
			return list;
		}
	}

	/** Phân trang (page >=1, size >0). */
	public List<News> findAll(int page, int size) throws Exception {
		String sql = "SELECT Id, Title, Content, Image, PostedDate, Author, ViewCount, "
				+ "       CategoryId, Home, Approved, ReporterId " + "FROM News " + "WHERE " + ND + " "
				+ "ORDER BY PostedDate DESC " + "OFFSET ? ROWS FETCH NEXT ? ROWS ONLY";
		try (Connection cn = DB.getConnection(); PreparedStatement ps = cn.prepareStatement(sql)) {
			ps.setInt(1, (page - 1) * size);
			ps.setInt(2, size);
			try (ResultSet rs = ps.executeQuery()) {
				List<News> list = new ArrayList<>();
				while (rs.next())
					list.add(map(rs));
				return list;
			}
		}
	}

	public int countAll() throws Exception {
		try (Connection c = DB.getConnection();
				PreparedStatement ps = c.prepareStatement("SELECT COUNT(*) FROM News WHERE " + ND);
				ResultSet rs = ps.executeQuery()) {
			return rs.next() ? rs.getInt(1) : 0;
		}
	}

	public int countPending() throws Exception {
		try (Connection c = DB.getConnection();
				PreparedStatement ps = c.prepareStatement("SELECT COUNT(*) FROM News WHERE Approved=0");
				ResultSet rs = ps.executeQuery()) {
			return rs.next() ? rs.getInt(1) : 0;
		}
	}

	// tìm tin đã được duyệt
	public List<News> findApproved(int limit) throws Exception {
		String sql = "SELECT TOP " + limit + " * FROM News WHERE " + ND + " AND Approved = 1 ORDER BY PostedDate DESC";
		try (Connection cn = DB.getConnection();
				PreparedStatement ps = cn.prepareStatement(sql);
				ResultSet rs = ps.executeQuery()) {
			List<News> list = new ArrayList<>();
			while (rs.next())
				list.add(map(rs));
			return list;
		}
	}

	// Tin bài trang chủ
	public List<News> findHomeApproved(int limit) throws SQLException {
		String sql = "SELECT n.Id, n.Title, n.[Content], n.Image, n.PostedDate, n.Author, n.ViewCount, "
				+ "       n.CategoryId, n.Home, n.Approved, n.ReporterId " + "FROM News n "
				+ "JOIN Categories c ON c.Id = n.CategoryId AND ISNULL(c.IsDelete,0)=0 "
				+ "JOIN Users u ON u.Id = n.ReporterId AND ISNULL(u.IsDelete,0)=0 " + "WHERE "
				+ ND.replace("IsDelete", "n.IsDelete") + " AND n.Approved=1 AND n.Home=1 "
				+ "ORDER BY n.PostedDate DESC " + "OFFSET 0 ROWS FETCH NEXT ? ROWS ONLY";

		try (var con = DB.getConnection(); var ps = con.prepareStatement(sql)) {
			ps.setInt(1, limit);
			try (var rs = ps.executeQuery()) {
				List<News> list = new ArrayList<>();
				while (rs.next())
					list.add(mapRow(rs));
				return list;
			}
		}
	}

	public void increaseViewCount(int id) throws Exception {
		String sql = "UPDATE News SET ViewCount = ViewCount + 1 WHERE Id = ?";
		try (Connection cn = DB.getConnection(); PreparedStatement ps = cn.prepareStatement(sql)) {
			ps.setInt(1, id);
			ps.executeUpdate();
		}
	}

	// ===== Mapping chung =====

	private News map(ResultSet rs) throws SQLException {
		News n = new News();
		n.setId(rs.getInt("Id"));
		n.setTitle(rs.getString("Title"));
		n.setContent(rs.getString("Content")); // cột [Content]
		n.setImage(rs.getString("Image")); // cột [Image]
		Timestamp ts = rs.getTimestamp("PostedDate");
		n.setPostedDate(ts != null ? ts.toLocalDateTime() : null);
		n.setAuthor(rs.getString("Author"));
		n.setViewCount(rs.getInt("ViewCount"));
		n.setCategoryId(rs.getInt("CategoryId"));
		n.setHome(rs.getBoolean("Home"));
		n.setApproved(rs.getBoolean("Approved"));

		int rep = rs.getInt("ReporterId");
		n.setReporterId(rs.wasNull() ? null : rep);
		return n;
	}

	/** Lấy các bài cùng chuyên mục (đã duyệt), sắp xếp mới nhất. */
	public List<News> findByCategoryId(int categoryId, int limit) throws Exception {
		String sql = "SELECT TOP " + limit
				+ " Id, Title, Content, Image, PostedDate, Author, ViewCount, CategoryId, Home, Approved, ReporterId"
				+ " FROM News WHERE " + ND + " AND Approved=1 AND CategoryId=?" + " ORDER BY PostedDate DESC";
		try (Connection cn = DB.getConnection(); PreparedStatement ps = cn.prepareStatement(sql)) {
			ps.setInt(1, categoryId);
			try (ResultSet rs = ps.executeQuery()) {
				List<News> list = new ArrayList<>();
				while (rs.next())
					list.add(map(rs));
				return list;
			}
		}
	}

	public List<News> findRelated(int categoryId, int excludeNewsId, int limit) throws Exception {
		String sql = "SELECT TOP " + limit
				+ " Id, Title, Content, Image, PostedDate, Author, ViewCount, CategoryId, Home, Approved, ReporterId"
				+ " FROM News WHERE " + ND + " AND Approved=1 AND CategoryId=? AND Id<>?" + " ORDER BY PostedDate DESC";
		try (Connection cn = DB.getConnection(); PreparedStatement ps = cn.prepareStatement(sql)) {
			ps.setInt(1, categoryId);
			ps.setInt(2, excludeNewsId);
			try (ResultSet rs = ps.executeQuery()) {
				List<News> list = new ArrayList<>();
				while (rs.next())
					list.add(map(rs));
				return list;
			}
		}
	}

	public List<News> listByReporter(int reporterId) throws Exception {
		String sql = "SELECT Id, Title, Content, Image, PostedDate, Author, ViewCount, "
				+ "       CategoryId, Home, Approved, ReporterId " + "FROM News " + "WHERE " + ND
				+ " AND ReporterId = ? " + "ORDER BY PostedDate DESC";
		try (Connection c = DB.getConnection(); PreparedStatement ps = c.prepareStatement(sql)) {
			ps.setInt(1, reporterId);
			try (ResultSet rs = ps.executeQuery()) {
				List<News> list = new ArrayList<>();
				while (rs.next())
					list.add(map(rs));
				return list;
			}
		}
	}

	// Lấy bài theo id + thuộc về phóng viên
	public News findByIdAndReporter(int id, int reporterId) throws Exception {
		String sql = "SELECT Id, Title, Content, Image, PostedDate, Author, ViewCount, "
				+ "       CategoryId, Home, Approved, ReporterId " + "FROM News " + "WHERE " + ND
				+ " AND Id = ? AND ReporterId = ?";
		try (Connection c = DB.getConnection(); PreparedStatement ps = c.prepareStatement(sql)) {
			ps.setInt(1, id);
			ps.setInt(2, reporterId);
			try (ResultSet rs = ps.executeQuery()) {
				return rs.next() ? map(rs) : null;
			}
		}
	}

	// Cập nhật bài; nếu includeImage=true thì cập nhật cột Image, ngược lại giữ
	// nguyên
	public int update(News n, boolean includeImage) throws Exception {
		String sql = includeImage
				? """
						 UPDATE News SET Title=?, Content=?, Image=?, CategoryId=?, Home=?, Approved=?, Author=?, PostedDate=GETDATE()
						 WHERE Id=?
						"""
				: """
						 UPDATE News SET Title=?, Content=?, CategoryId=?, Home=?, Approved=?, Author=?, PostedDate=GETDATE()
						 WHERE Id=?
						""";
		try (var c = DB.getConnection(); var ps = c.prepareStatement(sql)) {
			int i = 1;
			ps.setString(i++, n.getTitle());
			ps.setString(i++, n.getContent());
			if (includeImage)
				ps.setString(i++, n.getImage());
			ps.setInt(i++, n.getCategoryId());
			ps.setBoolean(i++, n.isHome());
			ps.setBoolean(i++, n.isApproved());
			ps.setString(i++, n.getAuthor());
			ps.setInt(i++, n.getId());
			return ps.executeUpdate();
		}
	}

	/**
	 * Tìm kiếm nâng cao với nhiều tùy chọn
	 * 
	 * @param keyword    từ khóa tìm kiếm
	 * @param categoryId ID chuyên mục (0 = tất cả)
	 * @param limit      số lượng kết quả tối đa
	 * @return danh sách bài viết phù hợp
	 */
	public List<News> searchAdvanced(String keyword, int categoryId, int limit) throws Exception {
		String kw = (keyword == null ? "" : keyword.trim());
		StringBuilder sql = new StringBuilder();
		sql.append("SELECT Id, Title, [Content], [Image], PostedDate, Author, ViewCount, ");
		sql.append("       CategoryId, [Home], Approved, ReporterId ");
		sql.append("FROM News WHERE ").append(ND).append(" AND Approved = 1 ");
		if (!kw.isEmpty())
			sql.append("AND (Title LIKE ? OR [Content] LIKE ?) ");
		if (categoryId > 0)
			sql.append("AND CategoryId = ? ");
		sql.append("ORDER BY PostedDate DESC OFFSET 0 ROWS FETCH NEXT ? ROWS ONLY");

		try (Connection cn = DB.getConnection(); PreparedStatement ps = cn.prepareStatement(sql.toString())) {
			int i = 1;
			if (!kw.isEmpty()) {
				String like = "%" + kw + "%";
				ps.setString(i++, like);
				ps.setString(i++, like);
			}
			if (categoryId > 0)
				ps.setInt(i++, categoryId);
			ps.setInt(i++, Math.max(0, limit));
			try (ResultSet rs = ps.executeQuery()) {
				List<News> list = new ArrayList<>();
				while (rs.next())
					list.add(map(rs));
				return list;
			}
		}
	}

	/**
	 * Đếm số lượng kết quả tìm kiếm
	 * 
	 * @param keyword    từ khóa tìm kiếm
	 * @param categoryId ID chuyên mục (0 = tất cả)
	 * @return số lượng bài viết phù hợp
	 */
	public int countSearchResults(String keyword, int categoryId) throws Exception {
		String kw = (keyword == null ? "" : keyword.trim());
		StringBuilder sql = new StringBuilder();
		sql.append("SELECT COUNT(*) FROM News WHERE ").append(ND).append(" AND Approved = 1 ");
		if (!kw.isEmpty())
			sql.append("AND (Title LIKE ? OR [Content] LIKE ?) ");
		if (categoryId > 0)
			sql.append("AND CategoryId = ? ");

		try (Connection cn = DB.getConnection(); PreparedStatement ps = cn.prepareStatement(sql.toString())) {
			int i = 1;
			if (!kw.isEmpty()) {
				String like = "%" + kw + "%";
				ps.setString(i++, like);
				ps.setString(i++, like);
			}
			if (categoryId > 0)
				ps.setInt(i++, categoryId);
			try (ResultSet rs = ps.executeQuery()) {
				return rs.next() ? rs.getInt(1) : 0;
			}
		}
	}

	/**
	 * Đếm tổng số bài viết của một reporter
	 */
	public int countByReporter(int reporterId) throws Exception {
		try (Connection c = DB.getConnection();
				PreparedStatement ps = c
						.prepareStatement("SELECT COUNT(*) FROM News WHERE " + ND + " AND ReporterId=?")) {
			ps.setInt(1, reporterId);
			try (ResultSet rs = ps.executeQuery()) {
				return rs.next() ? rs.getInt(1) : 0;
			}
		}
	}

	/**
	 * Đếm số bài chờ duyệt của một reporter
	 */
	public int countPendingByReporter(int reporterId) throws Exception {
		try (Connection c = DB.getConnection();
				PreparedStatement ps = c.prepareStatement(
						"SELECT COUNT(*) FROM News WHERE " + ND + " AND ReporterId=? AND Approved=0")) {
			ps.setInt(1, reporterId);
			try (ResultSet rs = ps.executeQuery()) {
				return rs.next() ? rs.getInt(1) : 0;
			}
		}
	}

	/**
	 * Đếm số bài đã duyệt của một reporter
	 */
	public int countApprovedByReporter(int reporterId) throws Exception {
		try (Connection c = DB.getConnection();
				PreparedStatement ps = c.prepareStatement(
						"SELECT COUNT(*) FROM News WHERE " + ND + " AND ReporterId=? AND Approved=1")) {
			ps.setInt(1, reporterId);
			try (ResultSet rs = ps.executeQuery()) {
				return rs.next() ? rs.getInt(1) : 0;
			}
		}
	}

	public List<News> findByReporterPending(int reporterId, int limit) {
		String sql = "SELECT Id, Title, Content, Image, PostedDate, Author, ViewCount, "
				+ "       CategoryId, Home, Approved, ReporterId " + "FROM News " + "WHERE " + ND
				+ " AND ReporterId = ? AND (Approved = 0 OR Approved IS NULL) " + "ORDER BY PostedDate DESC "
				+ "OFFSET 0 ROWS FETCH NEXT ? ROWS ONLY";
		List<News> list = new ArrayList<>();
		try (Connection con = DB.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {
			ps.setInt(1, reporterId);
			ps.setInt(2, limit);
			try (ResultSet rs = ps.executeQuery()) {
				while (rs.next())
					list.add(mapRow(rs));
			}
		} catch (SQLException e) {
			throw new RuntimeException(e);
		}
		return list;
	}

	public List<News> findByReporterPending(int reporterId) {
		return findByReporterPending(reporterId, 5); // mặc định show 5 bài
	}

	// CHÚ Ý: phương thức này CHỈ set Approved, KHÔNG đụng cột Home
	public void setApproved(int id, boolean approved) throws SQLException {
		String sql = "UPDATE News SET Approved=? WHERE Id=?";
		try (var con = DB.getConnection(); var ps = con.prepareStatement(sql)) {
			ps.setBoolean(1, approved);
			ps.setInt(2, id);
			ps.executeUpdate();
		}
	}

	public void setHome(int id, boolean home) throws SQLException {
		String sql = "UPDATE News SET Home=? WHERE Id=?";
		try (var con = DB.getConnection(); var ps = con.prepareStatement(sql)) {
			ps.setBoolean(1, home);
			ps.setInt(2, id);
			ps.executeUpdate();
		}
	}

	// Đếm bài CHỜ DUYỆT theo bộ lọc
	public int countPending(String q, Integer catId, Integer reporterId, LocalDate from, LocalDate to)
			throws SQLException {
		StringBuilder sb = new StringBuilder("SELECT COUNT(*) FROM News WHERE " + ND + " AND Approved = 0");
		List<Object> args = new ArrayList<>();
		if (catId != null) {
			sb.append(" AND CategoryId=?");
			args.add(catId);
		}
		if (reporterId != null) {
			sb.append(" AND ReporterId=?");
			args.add(reporterId);
		}
		if (from != null) {
			sb.append(" AND PostedDate >= ?");
			args.add(Timestamp.valueOf(from.atStartOfDay()));
		}
		if (to != null) {
			sb.append(" AND PostedDate < ?");
			args.add(Timestamp.valueOf(to.plusDays(1).atStartOfDay()));
		}
		if (q != null && !q.isBlank()) {
			sb.append(" AND (Title LIKE ? OR [Content] LIKE ?)");
			String like = "%" + q.trim() + "%";
			args.add(like);
			args.add(like);
		}
		try (var con = DB.getConnection(); var ps = con.prepareStatement(sb.toString())) {
			for (int i = 0; i < args.size(); i++)
				ps.setObject(i + 1, args.get(i));
			try (var rs = ps.executeQuery()) {
				rs.next();
				return rs.getInt(1);
			}
		}
	}

	// Lấy danh sách CHỜ DUYỆT theo bộ lọc + phân trang
	public List<News> findPendingPaged(String q, Integer catId, Integer reporterId, LocalDate from, LocalDate to,
			int offset, int limit) throws SQLException {
		StringBuilder sb = new StringBuilder("SELECT Id, Title, [Content], Image, PostedDate, Author, ViewCount,"
				+ "CategoryId, Home, Approved, ReporterId " + "FROM News WHERE " + ND + " AND Approved = 0");
		List<Object> args = new ArrayList<>();
		if (catId != null) {
			sb.append(" AND CategoryId=?");
			args.add(catId);
		}
		if (reporterId != null) {
			sb.append(" AND ReporterId=?");
			args.add(reporterId);
		}
		if (from != null) {
			sb.append(" AND PostedDate >= ?");
			args.add(Timestamp.valueOf(from.atStartOfDay()));
		}
		if (to != null) {
			sb.append(" AND PostedDate < ?");
			args.add(Timestamp.valueOf(to.plusDays(1).atStartOfDay()));
		}
		if (q != null && !q.isBlank()) {
			sb.append(" AND (Title LIKE ? OR [Content] LIKE ?)");
			String like = "%" + q.trim() + "%";
			args.add(like);
			args.add(like);
		}
		sb.append(" ORDER BY PostedDate DESC OFFSET ? ROWS FETCH NEXT ? ROWS ONLY");
		args.add(offset);
		args.add(limit);

		try (var con = DB.getConnection(); var ps = con.prepareStatement(sb.toString())) {
			for (int i = 0; i < args.size(); i++)
				ps.setObject(i + 1, args.get(i));
			try (var rs = ps.executeQuery()) {
				List<News> list = new ArrayList<>();
				while (rs.next())
					list.add(mapRow(rs));
				return list;
			}
		}
	}

	private News mapRow(ResultSet rs) throws SQLException {
		News n = new News();
		n.setId(rs.getInt("Id"));
		n.setTitle(rs.getString("Title"));
		n.setContent(rs.getString("Content"));
		n.setImage(rs.getString("Image"));
		n.setPostedDate(rs.getTimestamp("PostedDate").toLocalDateTime());
		n.setAuthor(rs.getString("Author"));
		n.setViewCount(rs.getInt("ViewCount"));
		n.setCategoryId(rs.getInt("CategoryId"));
		n.setHome(rs.getBoolean("Home"));
		n.setApproved(rs.getBoolean("Approved"));
		int rid = rs.getInt("ReporterId");
		n.setReporterId(rs.wasNull() ? null : rid);
		return n;
	}

	// Tiện ích lấy tập bài chờ duyệt (không phân trang) – nếu còn dùng nơi khác
	public List<News> findPending() throws SQLException {
		return findPendingPaged(null, null, null, null, null, 0, 50);
	}

	// Tìm kiếm có phân trang
	public List<News> searchAdvancedPaged(String keyword, int categoryId, int page, int size) throws Exception {
		String kw = (keyword == null ? "" : keyword.trim());

		StringBuilder sql = new StringBuilder();
		sql.append("SELECT Id, Title, [Content], [Image], PostedDate, Author, ViewCount, ")
				.append("       CategoryId, [Home], Approved, ReporterId ").append("FROM News WHERE ").append(ND)
				.append(" AND Approved = 1 ");

		List<Object> params = new ArrayList<>();

		if (!kw.isEmpty()) {
			sql.append("AND (Title LIKE ? OR [Content] LIKE ?) ");
			String like = "%" + kw + "%";
			params.add(like);
			params.add(like);
		}
		if (categoryId > 0) {
			sql.append("AND CategoryId = ? ");
			params.add(categoryId);
		}

		sql.append("ORDER BY PostedDate DESC OFFSET ? ROWS FETCH NEXT ? ROWS ONLY ");

		int offset = (Math.max(1, page) - 1) * Math.max(1, size);
		params.add(offset);
		params.add(size);

		try (Connection cn = DB.getConnection(); PreparedStatement ps = cn.prepareStatement(sql.toString())) {
			for (int i = 0; i < params.size(); i++)
				ps.setObject(i + 1, params.get(i));
			try (ResultSet rs = ps.executeQuery()) {
				List<News> list = new ArrayList<>();
				while (rs.next())
					list.add(map(rs));
				return list;
			}
		}
	}

	// Lấy ngẫu nhiên N bài đã duyệt cùng chuyên mục, loại trừ bài hiện tại
	public List<News> findRelatedRandom(int categoryId, int excludeNewsId, int limit) throws Exception {
		String sql = "SELECT TOP " + limit
				+ " Id, Title, Content, Image, PostedDate, Author, ViewCount, CategoryId, Home, Approved, ReporterId"
				+ " FROM News WHERE " + ND + " AND Approved=1 AND CategoryId=? AND Id<>?" + " ORDER BY NEWID()";
		try (Connection cn = DB.getConnection(); PreparedStatement ps = cn.prepareStatement(sql)) {
			ps.setInt(1, categoryId);
			ps.setInt(2, excludeNewsId);
			try (ResultSet rs = ps.executeQuery()) {
				List<News> list = new ArrayList<>();
				while (rs.next())
					list.add(map(rs));
				return list;
			}
		}
	}

	public List<News> findByIds(List<Integer> ids) throws Exception {
		if (ids == null || ids.isEmpty())
			return List.of();
		String in = ids.stream().map(i -> "?").collect(java.util.stream.Collectors.joining(","));
		String sql = "SELECT Id, Title, CategoryId FROM dbo.News WHERE " + ND + " AND Id IN (" + in + ")";
		try (Connection cn = DB.getConnection(); PreparedStatement ps = cn.prepareStatement(sql)) {
			int idx = 1;
			for (Integer id : ids)
				ps.setInt(idx++, id);
			try (ResultSet rs = ps.executeQuery()) {
				List<News> list = new ArrayList<>();
				while (rs.next()) {
					News n = new News();
					n.setId(rs.getInt("Id"));
					n.setTitle(rs.getString("Title"));
					n.setCategoryId((Integer) rs.getObject("CategoryId"));
					list.add(n);
				}
				return list;
			}
		}
	}

	public List<News> searchAdvancedPagedByReporter(String keyword, int categoryId, Integer reporterId, int page,
			int size) throws Exception {
		String kw = (keyword == null ? "" : keyword.trim());

		StringBuilder sql = new StringBuilder();
		sql.append("SELECT Id, Title, [Content], [Image], PostedDate, Author, ViewCount, ")
				.append("       CategoryId, [Home], Approved, ReporterId ").append("FROM News WHERE ").append(ND)
				.append(" AND Approved = 1 ");

		java.util.List<Object> params = new java.util.ArrayList<>();

		if (!kw.isEmpty()) {
			sql.append("AND (Title LIKE ? OR [Content] LIKE ?) ");
			String like = "%" + kw + "%";
			params.add(like);
			params.add(like);
		}
		if (categoryId > 0) {
			sql.append("AND CategoryId = ? ");
			params.add(categoryId);
		}
		if (reporterId != null) {
			sql.append("AND ReporterId = ? ");
			params.add(reporterId);
		}

		sql.append("ORDER BY PostedDate DESC OFFSET ? ROWS FETCH NEXT ? ROWS ONLY ");
		int offset = (Math.max(1, page) - 1) * Math.max(1, size);
		params.add(offset);
		params.add(size);

		try (var cn = DB.getConnection(); var ps = cn.prepareStatement(sql.toString())) {
			for (int i = 0; i < params.size(); i++)
				ps.setObject(i + 1, params.get(i));
			try (var rs = ps.executeQuery()) {
				java.util.List<News> list = new java.util.ArrayList<>();
				while (rs.next())
					list.add(map(rs));
				return list;
			}
		}
	}

	public int countSearchResultsByReporter(String keyword, int categoryId, Integer reporterId) throws Exception {
		String kw = (keyword == null ? "" : keyword.trim());

		StringBuilder sql = new StringBuilder();
		sql.append("SELECT COUNT(*) FROM News WHERE ").append(ND).append(" AND Approved = 1 ");

		java.util.List<Object> params = new java.util.ArrayList<>();

		if (!kw.isEmpty()) {
			sql.append("AND (Title LIKE ? OR [Content] LIKE ?) ");
			String like = "%" + kw + "%";
			params.add(like);
			params.add(like);
		}
		if (categoryId > 0) {
			sql.append("AND CategoryId = ? ");
			params.add(categoryId);
		}
		if (reporterId != null) {
			sql.append("AND ReporterId = ? ");
			params.add(reporterId);
		}

		try (var cn = DB.getConnection(); var ps = cn.prepareStatement(sql.toString())) {
			for (int i = 0; i < params.size(); i++)
				ps.setObject(i + 1, params.get(i));
			try (var rs = ps.executeQuery()) {
				return rs.next() ? rs.getInt(1) : 0;
			}
		}
	}
	
	// NewsDAO.java  (thêm vào class)
	private static final String NEWS_SELECT_L10N = """
	  SELECT n.Id,
	         COALESCE(nt_req.Title, nt_vi.Title, n.Title)       AS Title,
	         COALESCE(nt_req.Content, nt_vi.Content, n.Content) AS [Content],
	         n.[Image], n.PostedDate, n.Author, n.ViewCount,
	         n.CategoryId, n.[Home], n.Approved, n.ReporterId
	  FROM News n
	  LEFT JOIN NewsTranslations nt_req
	         ON nt_req.NewsId = n.Id AND nt_req.[Lang] = ?
	  LEFT JOIN NewsTranslations nt_vi
	         ON nt_vi.NewsId = n.Id AND nt_vi.[Lang] = 'vi'
	""";

	private static String normalizeLang(String lang) {
	  return (lang == null || lang.isBlank()) ? "vi" : lang.trim();
	}

	// ========== LOCALIZED QUERIES ==========

	public List<News> findHomeApprovedLocalized(String lang, int limit) throws SQLException {
	  String sql = NEWS_SELECT_L10N +
	      "JOIN Categories c ON c.Id = n.CategoryId AND ISNULL(c.IsDelete,0)=0 " +
	      "LEFT JOIN Users u ON u.Id = n.ReporterId " +
	      "WHERE " + ND.replace("IsDelete", "n.IsDelete") + " AND n.Approved=1 AND n.[Home]=1 " +
	      "AND (u.Id IS NULL OR ISNULL(u.IsDelete,0)=0) " +
	      "ORDER BY n.PostedDate DESC OFFSET 0 ROWS FETCH NEXT ? ROWS ONLY";
	  try (var con = DB.getConnection(); var ps = con.prepareStatement(sql)) {
	    ps.setString(1, normalizeLang(lang)); // param cho nt_req.Lang
	    ps.setInt(2, limit);
	    try (var rs = ps.executeQuery()) {
	      List<News> list = new ArrayList<>();
	      while (rs.next()) list.add(map(rs));
	      return list;
	    }
	  }
	}

	public List<News> findTopHotLocalized(String lang, int limit) throws Exception {
	  String sql = NEWS_SELECT_L10N +
	      "WHERE " + ND.replace("IsDelete", "n.IsDelete") + " AND n.Approved=1 " +
	      "ORDER BY n.ViewCount DESC, n.PostedDate DESC " +
	      "OFFSET 0 ROWS FETCH NEXT ? ROWS ONLY";
	  try (var cn = DB.getConnection(); var ps = cn.prepareStatement(sql)) {
	    ps.setString(1, normalizeLang(lang));
	    ps.setInt(2, Math.max(0, limit));
	    try (var rs = ps.executeQuery()) {
	      List<News> list = new ArrayList<>();
	      while (rs.next()) list.add(map(rs));
	      return list;
	    }
	  }
	}

	public List<News> findTopNewLocalized(String lang, int limit) throws Exception {
	  String sql = NEWS_SELECT_L10N +
	      "WHERE " + ND.replace("IsDelete", "n.IsDelete") + " AND n.Approved=1 " +
	      "ORDER BY n.PostedDate DESC " +
	      "OFFSET 0 ROWS FETCH NEXT ? ROWS ONLY";
	  try (var cn = DB.getConnection(); var ps = cn.prepareStatement(sql)) {
	    ps.setString(1, normalizeLang(lang));
	    ps.setInt(2, Math.max(0, limit));
	    try (var rs = ps.executeQuery()) {
	      List<News> list = new ArrayList<>();
	      while (rs.next()) list.add(map(rs));
	      return list;
	    }
	  }
	}

	public News findByIdLocalized(int id, String lang) throws Exception {
	  String sql = NEWS_SELECT_L10N + "WHERE " + ND.replace("IsDelete", "n.IsDelete") + " AND n.Id=?";
	  try (var cn = DB.getConnection(); var ps = cn.prepareStatement(sql)) {
	    ps.setString(1, normalizeLang(lang));
	    ps.setInt(2, id);
	    try (var rs = ps.executeQuery()) {
	      return rs.next() ? map(rs) : null;
	    }
	  }
	}

	/** Danh sách theo chuyên mục (đã duyệt), localized */
	public List<News> findByCategoryLocalized(int categoryId, String lang) throws Exception {
	  String sql = NEWS_SELECT_L10N +
	      "LEFT JOIN Users u ON u.Id = n.ReporterId " +
	      "WHERE " + ND.replace("IsDelete", "n.IsDelete") + " AND n.Approved=1 AND n.CategoryId=? " +
	      "AND (u.Id IS NULL OR ISNULL(u.IsDelete,0)=0) " +
	      "ORDER BY n.PostedDate DESC";
	  try (var cn = DB.getConnection(); var ps = cn.prepareStatement(sql)) {
	    ps.setString(1, normalizeLang(lang));
	    ps.setInt(2, categoryId);
	    try (var rs = ps.executeQuery()) {
	      List<News> list = new ArrayList<>();
	      while (rs.next()) list.add(map(rs));
	      return list;
	    }
	  }
	}
	
	
	/** 
	 * Lấy các bài liên quan (cùng chuyên mục), đã duyệt, ưu tiên bản dịch theo lang.
	 * Fallback sang bản gốc nếu chưa có bản dịch.
	 */
	public List<News> findRelatedLocalized(String lang, int categoryId, int excludeNewsId, int limit) throws Exception {
	    String useLang = (lang == null || lang.isBlank()) ? "vi" : lang.trim();

	    String sql = 
	        "SELECT TOP " + Math.max(0, limit) + " " +
	        "       n.Id, " +
	        "       COALESCE(nt.Title, n.Title)      AS Title, " +
	        "       COALESCE(nt.[Content], n.[Content]) AS [Content], " +
	        "       n.[Image], n.PostedDate, n.Author, n.ViewCount, " +
	        "       n.CategoryId, n.[Home], n.Approved, n.ReporterId " +
	        "FROM   dbo.News n " +
	        "LEFT JOIN dbo.NewsTranslations nt " +
	        "       ON nt.NewsId = n.Id AND nt.[Lang] = ? " +
	        "WHERE  ISNULL(n.IsDelete,0)=0 " +
	        "  AND  n.Approved = 1 " +
	        "  AND  n.CategoryId = ? " +
	        "  AND  n.Id <> ? " +
	        "ORDER BY n.PostedDate DESC";

	    try (Connection cn = DB.getConnection();
	         PreparedStatement ps = cn.prepareStatement(sql)) {

	        int i = 1;
	        ps.setString(i++, useLang);
	        ps.setInt(i++, categoryId);
	        ps.setInt(i++, excludeNewsId);

	        try (ResultSet rs = ps.executeQuery()) {
	            List<News> list = new ArrayList<>();
	            while (rs.next()) {
	                list.add(map(rs)); // dùng hàm map(ResultSet) có sẵn trong NewsDAO
	            }
	            return list;
	        }
	    }
	}
	
	// com/newsportal/dao/NewsDAO.java
	public int upsertTranslation(int newsId, String lang, String title, String excerpt, String content) throws Exception {
	    String sql = """
	        IF EXISTS (SELECT 1 FROM dbo.NewsTranslations WHERE NewsId=? AND [Lang]=?)
	          UPDATE dbo.NewsTranslations
	             SET Title=?, Excerpt=?, [Content]=?
	           WHERE NewsId=? AND [Lang]=?
	        ELSE
	          INSERT INTO dbo.NewsTranslations (NewsId, [Lang], Title, Excerpt, [Content])
	          VALUES (?, ?, ?, ?, ?)
	    """;
	    try (var cn = DB.getConnection(); var ps = cn.prepareStatement(sql)) {
	        int i=1;
	        ps.setInt(i++, newsId);      ps.setString(i++, lang);
	        ps.setString(i++, title);    ps.setString(i++, excerpt);   ps.setString(i++, content);
	        ps.setInt(i++, newsId);      ps.setString(i++, lang);
	        ps.setInt(i++, newsId);      ps.setString(i++, lang);
	        ps.setString(i++, title);    ps.setString(i++, excerpt);   ps.setString(i++, content);
	        return ps.executeUpdate();
	    }
	}


}
