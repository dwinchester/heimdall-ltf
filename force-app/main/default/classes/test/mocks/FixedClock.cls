/**
 * Test double for {@link IClock} that always returns a configured timestamp.
 */
@isTest
public class FixedClock implements IClock {
    private Datetime fixedNow;

    public FixedClock(Datetime fixedNow) {
        this.fixedNow = fixedNow;
    }

    public Datetime now() {
        return fixedNow;
    }
}

