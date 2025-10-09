package com.newsportal.util;

import java.sql.ResultSet;
import java.sql.SQLException;

/** Hàm map 1 dòng ResultSet -> đối tượng T */
@FunctionalInterface
public interface RowMapper<T> {
    T map(ResultSet rs) throws SQLException;
}
