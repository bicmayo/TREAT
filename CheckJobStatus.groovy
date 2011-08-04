#!/usr/bin/env groovy
import java.util.List;

if(args.length == 0) {
        println "usage: CheckJobStatus.groovy jobIDs"
        System.exit 0;
}
List<String> jobNumbers = new ArrayList<String>();
for(int i = 0; i < args.length; i++) {
	jobNumbers.add(args[i]);
}

while(!allJobsDone(jobNumbers)) {
	Thread.sleep(60000);
}

public static boolean allJobsDone(List jobList) {
	for(job in jobList) {
		println "checking job status";
		def grepCommand = "qstat";	
		def output = grepCommand.execute().text;
		
        if(output =~ /.*$job.*/) {
        	println " " + job;
            return false;
        }
	}
	return true;
}
