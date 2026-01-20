/**
 * Production implementation of {@link IClock} that delegates to {@code System.now()}.
 */
public class SystemClock implements IClock {
    public Datetime now() {
        return System.now();
    }
}

