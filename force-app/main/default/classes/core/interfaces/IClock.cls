/**
 * Abstraction over {@code System.now()} for time control in tests.
 *
 * Production implementation: {@link SystemClock}.
 */
public interface IClock {
    /**
     * Returns the current timestamp.
     *
     * @return Current timestamp
     */
    Datetime now();
}

