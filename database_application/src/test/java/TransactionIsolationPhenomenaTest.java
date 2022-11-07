import lombok.SneakyThrows;
import model.Subject;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.core.RowMapper;
import org.springframework.test.context.ContextConfiguration;
import org.springframework.test.context.junit.jupiter.SpringExtension;

import javax.sql.DataSource;
import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.List;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.atomic.AtomicInteger;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertNotEquals;

@ContextConfiguration(classes = {TestConfig.class})
@ExtendWith(SpringExtension.class)
public class TransactionIsolationPhenomenaTest {
    private static final ExecutorService executor = Executors.newFixedThreadPool(Runtime.getRuntime().availableProcessors());
    private static final AtomicInteger id = new AtomicInteger(1000);

    private static final String JDBC_TEMPLATE_INSERT = "INSERT INTO subject(subject_id, tutor, subject_name) VALUES(?, ?, ?)";
    private static final String INSERT_SUBJECT = "INSERT INTO subject(subject_id, subject_name, tutor) VALUES (%d, '%s', '%s');";
    private static final String JDBC_TEMPLATE_DELETE = "DELETE FROM subject WHERE subject_id = ?";
    private static final String UPDATE_TEMPLATE = "UPDATE subject SET subject_name = concat(subject_name::text, '%s') WHERE subject_id = %d";
    private static final String SELECT_FROM_SUBJECT_WHERE_NAME = "SELECT subject_id, subject_name, tutor FROM subject WHERE subject_name = '%s'";
    private static final String COUNT_OF_SUBJECTS = "SELECT COUNT(*) FROM subject";
    private static final String SELECT_FROM_SUBJECT_WHERE_ID_RANGE = "SELECT count(subject_id) AS count FROM subject WHERE subject_id BETWEEN 0 AND 2000";

    @Autowired
    private DataSource dataSource;
    @Autowired
    private JdbcTemplate jdbcTemplate;
    @Autowired
    private RowMapper<Subject> subjectRowMapper;

    @Test
    @DisplayName("Serializable isolation level test")
    public void testSerializableIsolationLevel() throws SQLException {
        try (final Connection connection1 = dataSource.getConnection();
             final Connection connection2 = dataSource.getConnection();
             final Statement statement1 = connection1.createStatement();
             final Statement statement2 = connection2.createStatement()
        ) {
            connection1.setTransactionIsolation(Connection.TRANSACTION_SERIALIZABLE);
            connection1.setAutoCommit(false);
            ResultSet resultSet = statement1.executeQuery(COUNT_OF_SUBJECTS);
            resultSet.next();
            long firstCount = resultSet.getLong(1);

            connection2.setTransactionIsolation(Connection.TRANSACTION_SERIALIZABLE);
            connection2.setAutoCommit(false);
            final int id = TransactionIsolationPhenomenaTest.id.incrementAndGet();
            String command = String.format(INSERT_SUBJECT, id, "subject_name", "tutor");
            statement2.executeUpdate(command, Statement.RETURN_GENERATED_KEYS);
            connection2.commit();

            resultSet = statement1.executeQuery(COUNT_OF_SUBJECTS);
            resultSet.next();
            long secondCount = resultSet.getLong(1);
            assertEquals(firstCount, secondCount);
        } finally {
            jdbcTemplate.update(JDBC_TEMPLATE_DELETE, id);
        }
    }

    @Test
    @DisplayName("Should lost updates when transactions executing concurrently")
    public void shouldLostUpdatesWhenTransactionsExecutingConcurrently() throws InterruptedException {
        try {
            final int id = TransactionIsolationPhenomenaTest.id.incrementAndGet();
            final String tutor = "tutor" + id;
            jdbcTemplate.update(JDBC_TEMPLATE_INSERT, id, tutor, "");
            executor.execute(() -> doUpdate(id, "qwe"));
            executor.execute(() -> doUpdate(id, "rty"));

            final List<Subject> subjects = jdbcTemplate.query(String.format(SELECT_FROM_SUBJECT_WHERE_NAME, "qwerty"), subjectRowMapper);
            assertEquals(0, subjects.size());

            Thread.sleep(1_000);
            final List<Subject> subjects1 = jdbcTemplate.query(String.format(SELECT_FROM_SUBJECT_WHERE_NAME, "qwe"), subjectRowMapper);
            final List<Subject> subjects2 = jdbcTemplate.query(String.format(SELECT_FROM_SUBJECT_WHERE_NAME, "rty"), subjectRowMapper);
            assertEquals(1, subjects1.size() + subjects2.size());
        } finally {
            jdbcTemplate.update(JDBC_TEMPLATE_DELETE, id);
        }
    }

    @SneakyThrows
    private void doUpdate(final int id, final String name) {
        try (final Connection connection = dataSource.getConnection();
             final Statement statement = connection.createStatement()
        ) {
            String command = String.format(UPDATE_TEMPLATE, name, id);
            statement.execute(command);
            Thread.sleep(1_000);
            connection.commit();
        }
    }

    @Test
    @DisplayName("Should return phantom rows when query executes multiple times in TX and TXs executing concurrently")
    public void shouldReturnPhantomRowsWhenQueryExecutesMultipleTimesInTxAndTxsExecutingConcurrently() {
        final int id = TransactionIsolationPhenomenaTest.id.incrementAndGet();
        try {
            executor.execute(() -> doInsertWithDelay(id));
            doRangeSelectsInTx();
        } finally {
            jdbcTemplate.update(JDBC_TEMPLATE_DELETE, id);
        }
    }

    @SneakyThrows
    private void doInsertWithDelay(final int id) {
        // waiting for 1st select to complete
        Thread.sleep(1_000);
        jdbcTemplate.update(JDBC_TEMPLATE_INSERT, id, "", "");
        System.out.println("phantom read: insert done");
    }

    @SneakyThrows
    private void doRangeSelectsInTx() {
        try (final Connection connection = dataSource.getConnection();
             final Statement statement = connection.createStatement()) {
            final int count1 = executeRangeSelectStatement(statement);
            System.out.println("phantom read: First select done");

            // waiting for another query to insert record in range
            Thread.sleep(7_000);

            final int count2 = executeRangeSelectStatement(statement);
            System.out.println("phantom read: Second select done");
            System.out.printf("phantom read: First select rows count: %d Second select rows count: %d%n", count1, count2);
            assertNotEquals(count1, count2);
        }
    }

    private int executeRangeSelectStatement(final Statement statement) throws SQLException {
        final ResultSet resultSet = statement.executeQuery(SELECT_FROM_SUBJECT_WHERE_ID_RANGE);
        resultSet.next();
        return resultSet.getInt("count");
    }

}
