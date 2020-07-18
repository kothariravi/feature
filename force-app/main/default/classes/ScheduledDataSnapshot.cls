global class ScheduledDataSnapshot implements Schedulable {
    global void execute(SchedulableContext schedulableContext) {
        DataSnapshotHandler.takeSnapshot();
    }
}