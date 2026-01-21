/**
 * Lightweight assertions around governor usage to keep tests fast.
 *
 * This is intentionally opinionated: tune thresholds to match your team's definition of "fast".
 */
@isTest
public class TestLimits {
    public static void assertWithin(Integer maxDml, Integer maxSoql, Integer maxCpuMs) {
        System.assert(
            Limits.getDmlStatements() <= maxDml,
            'DML statements exceeded: ' + Limits.getDmlStatements()
        );
        System.assert(
            Limits.getQueries() <= maxSoql,
            'SOQL queries exceeded: ' + Limits.getQueries()
        );
        System.assert(
            Limits.getCpuTime() <= maxCpuMs,
            'CPU time exceeded: ' + Limits.getCpuTime() + 'ms'
        );
    }

    public static void assertFastDefaults() {
        assertWithin(5, 5, 50);
    }
}
