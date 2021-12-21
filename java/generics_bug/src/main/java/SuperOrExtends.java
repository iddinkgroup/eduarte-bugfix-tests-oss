import java.util.Collections;
import java.util.List;

public class SuperOrExtends {
    public <X extends SuperOrExtends> void testProblem(BugTrigger<X> param1,
                                                       List<BugTrigger<? extends SuperOrExtends>> param2) {

        // Compile bug introduced in 8u292 (works in 8u282)
        param2.stream()
                .map(ref -> (BugTrigger<? extends SuperOrExtends>) ref)
                .forEach(ref -> updateValues(param1.trigger(ref), Collections.singletonList(ref)));

        // Works in 9, fails in 8.u282, remove comments to see that
        /* remove me to see the next part of the code fail to compile with 8u282
        param2.stream()
                .map(ref -> (BugTrigger<? extends SuperOrExtends>) ref)
                .forEach(ref -> updateValuesNoList(param1.trigger(ref), ref));
           remove me to see the above code fail compiling with 8u282 */
    }

    private static class BugTrigger<B> {
        public <U extends SuperOrExtends> BugTrigger<U> trigger(BugTrigger<U> param) {
            return null;
        }
    }

    private <A extends SuperOrExtends> void updateValues(
            BugTrigger<A> param1,
            List<BugTrigger<? super A>> param2) {
    }

    private <A extends SuperOrExtends> void updateValuesNoList(
            BugTrigger<A> param1,
            BugTrigger<? super A> param2) {
    }
}
