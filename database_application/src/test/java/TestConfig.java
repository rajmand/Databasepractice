
import com.zaxxer.hikari.HikariDataSource;
import model.Subject;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.ComponentScan;
import org.springframework.context.annotation.Configuration;
import com.zaxxer.hikari.HikariConfig;
import org.springframework.jdbc.core.JdbcTemplate;
import org.postgresql.ds.PGSimpleDataSource;
import org.springframework.jdbc.core.RowMapper;

@Configuration
public class TestConfig {

    private static final String user = "postgres";
    private static final String password = "admin";
    private static final String database = "cdp_program";

    @Bean
    public HikariDataSource dataSource() {
        final HikariConfig hikariConfig = new HikariConfig();
        hikariConfig.setJdbcUrl("jdbc:postgresql://localhost:5432/" + database);
        hikariConfig.setUsername(user);
        hikariConfig.setPassword(password);
        hikariConfig.setDriverClassName("org.postgresql.Driver");
        hikariConfig.setAutoCommit(false);
        hikariConfig.setTransactionIsolation("TRANSACTION_READ_UNCOMMITTED");
        hikariConfig.setConnectionTimeout(10_000);

        return new HikariDataSource(hikariConfig);
    }


    @Bean
    public JdbcTemplate jdbcTemplate() {
        final PGSimpleDataSource dataSource = new PGSimpleDataSource();
        dataSource.setServerNames(new String[]{"localhost"});
        dataSource.setDatabaseName(database);
        dataSource.setUser(user);
        dataSource.setPassword(password);
        return new JdbcTemplate(dataSource);
    }

    @Bean
    public RowMapper<Subject> subjectRowMapper() {
        return (rs, rowNum) -> {
            final int id = rs.getInt("subject_id");
            final String name = rs.getString("subject_name");
            final String tutor = rs.getString("tutor");

            return new Subject(id, name, tutor);
        };
    }

}
