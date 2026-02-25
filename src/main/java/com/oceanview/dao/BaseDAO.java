package com.oceanview.dao;

import java.sql.SQLException;
import java.util.List;
import java.util.Optional;

public interface BaseDAO<T, ID> {
    T save(T entity) throws SQLException;
    T update(T entity) throws SQLException;
    boolean delete(ID id) throws SQLException;
    Optional<T> findById(ID id) throws SQLException;
    List<T> findAll() throws SQLException;
    long count() throws SQLException;
}