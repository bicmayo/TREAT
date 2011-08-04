#; Input file name should be of the form sample1.txt, sample2.txt...sample8.txt. The files should contain the %values at each depth of coverage.
#; Usage: Rscript coverage_plot.r [target region] [sample names space seperated]
#;Example: Rscript coverage_plot.r 50377064 A244 A345

stdin = commandArgs() 

for (i in 1:1)
{
	if (length(stdin)==7)
	{
	#;number_of_samples= as.integer(stdin[7])
	target=as.integer(stdin[6])
	samplename1=as.character(stdin[7])
	file1=paste(samplename1,".coverage.out", sep="", collapse=NULL)
	sample1=as.matrix(read.table(file=file1))
	percent1=(sample1/target)*100
	jpeg(file="coverage.jpeg", width = 1190, height = 1190, quality=100, res=100)
 	plot(percent1,xlim=c(1,nrow(sample1)),ylim=c(0,115),main="Coverage across target regions at different depths of coverage",xlab="Depth of coverage",ylab="Percent coverage", col="blue",type="o",cex=0.6)
 	legend((nrow(sample1)-40),15,c(samplename1), cex=0.7, col=c("blue"), pch=21, lty=1)
 	dev.off()
	}

	else if (length(stdin)==8)
	{
	target=as.integer(stdin[6])
	samplename1=as.character(stdin[7])
	samplename2=as.character(stdin[8])
	file1=paste(samplename1,".coverage.out", sep="", collapse=NULL)
	file2=paste(samplename2,".coverage.out", sep="", collapse=NULL)
	sample1=as.matrix(read.table(file=file1))
	sample2=as.matrix(read.table(file=file2))
	percent1=(sample1/target)*100
	percent2=(sample2/target)*100
	jpeg(file="coverage.jpeg", width = 1190, height = 1190, quality=100, res=100)
	plot(percent1,xlim=c(1,nrow(sample1)),ylim=c(0,115),main="Coverage across target regions at different depths of coverage",xlab="Depth of coverage",ylab="Percent coverage", col="blue",type="o",cex=0.6)
	par(new=TRUE)
	plot(percent2,xlim=c(1,nrow(sample2)),ylim=c(0,115),xlab="Depth of coverage",ylab="Percent coverage", col="green",type="o",cex=0.6)
	legend((nrow(sample1)-40),15,c(samplename1, samplename2), cex=0.7, col=c("blue", "green"), pch=21, lty=1)
	dev.off()
	}

	else if (length(stdin)==9)
	{
	target=as.integer(stdin[6])
	samplename1=as.character(stdin[7])
	samplename2=as.character(stdin[8])
	samplename3=as.character(stdin[9])
	file1=paste(samplename1,".coverage.out", sep="", collapse=NULL)
	file2=paste(samplename2,".coverage.out", sep="", collapse=NULL)
	file3=paste(samplename3,".coverage.out", sep="", collapse=NULL)
	sample1=as.matrix(read.table(file=file1))
	sample2=as.matrix(read.table(file=file2))
	sample3=as.matrix(read.table(file=file3))
	percent1=(sample1/target)*100
	percent2=(sample2/target)*100
	percent3=(sample3/target)*100
	jpeg(file="coverage.jpeg", width = 1190, height = 1190, quality=100, res=100)
	plot(percent1,xlim=c(1,nrow(sample1)),ylim=c(0,115),main="Coverage across target regions at different depths of coverage",xlab="Depth of coverage",ylab="Percent coverage", col="blue",type="o",cex=0.6)
	par(new=TRUE)
	plot(percent2,xlim=c(1,nrow(sample2)),ylim=c(0,115),xlab="Depth of coverage",ylab="Percent coverage", col="green",type="o",cex=0.6)
	par(new=TRUE)
	plot(percent3,xlim=c(1,nrow(sample3)),ylim=c(0,115),xlab="Depth of coverage",ylab="Percent coverage", col="red",type="o",cex=0.6)
	legend((nrow(sample1)-40),15,c(samplename1, samplename2, samplename3), cex=0.7, col=c("blue", "green", "red"), pch=21, lty=1)
	dev.off()
	}

	else if (length(stdin)==10)
	{
	target=as.integer(stdin[6])
	samplename1=as.character(stdin[7])
	samplename2=as.character(stdin[8])
	samplename3=as.character(stdin[9])
	samplename4=as.character(stdin[10])
	file1=paste(samplename1,".coverage.out", sep="", collapse=NULL)
	file2=paste(samplename2,".coverage.out", sep="", collapse=NULL)
	file3=paste(samplename3,".coverage.out", sep="", collapse=NULL)
	file4=paste(samplename4,".coverage.out", sep="", collapse=NULL)
	sample1=as.matrix(read.table(file=file1))
	sample2=as.matrix(read.table(file=file2))
	sample3=as.matrix(read.table(file=file3))
	sample4=as.matrix(read.table(file=file4))
	percent1=(sample1/target)*100
	percent2=(sample2/target)*100
	percent3=(sample3/target)*100
	percent4=(sample4/target)*100
	jpeg(file="coverage.jpeg", width = 1190, height = 1190, quality=100, res=100)
	plot(percent1,xlim=c(1,nrow(sample1)),ylim=c(0,115),main="Coverage across target regions at different depths of coverage",xlab="Depth of coverage",ylab="Percent coverage", col="blue",type="o",cex=0.6)
	par(new=TRUE)
	plot(percent2,xlim=c(1,nrow(sample2)),ylim=c(0,115),xlab="Depth of coverage",ylab="Percent coverage", col="green",type="o",cex=0.6)
	par(new=TRUE)
	plot(percent3,xlim=c(1,nrow(sample3)),ylim=c(0,115),xlab="Depth of coverage",ylab="Percent coverage", col="red",type="o",cex=0.6)
	par(new=TRUE)
	plot(percent4,xlim=c(1,nrow(sample4)),ylim=c(0,115),xlab="Depth of coverage",ylab="Percent coverage", col="black",type="o",cex=0.6)
	legend((nrow(sample1)-40),15,c(samplename1, samplename2, samplename3, samplename4), cex=0.7, col=c("blue", "green", "red", "black"), pch=21, lty=1)
	dev.off()
	}

	else if (length(stdin)==11)
	{
	target=as.integer(stdin[6])
	samplename1=as.character(stdin[7])
	samplename2=as.character(stdin[8])
	samplename3=as.character(stdin[9])
	samplename4=as.character(stdin[10])
	samplename5=as.character(stdin[11])
	file1=paste(samplename1,".coverage.out", sep="", collapse=NULL)
	file2=paste(samplename2,".coverage.out", sep="", collapse=NULL)
	file3=paste(samplename3,".coverage.out", sep="", collapse=NULL)
	file4=paste(samplename4,".coverage.out", sep="", collapse=NULL)
	file5=paste(samplename5,".coverage.out", sep="", collapse=NULL)
	sample1=as.matrix(read.table(file=file1))
	sample2=as.matrix(read.table(file=file2))
	sample3=as.matrix(read.table(file=file3))
	sample4=as.matrix(read.table(file=file4))
	sample5=as.matrix(read.table(file=file5))
	percent1=(sample1/target)*100
	percent2=(sample2/target)*100
	percent3=(sample3/target)*100
	percent4=(sample4/target)*100
	percent5=(sample5/target)*100
	jpeg(file="coverage.jpeg", width = 1190, height = 1190, quality=100, res=100)
	plot(percent1,xlim=c(1,nrow(sample1)),ylim=c(0,115),main="Coverage across target regions at different depths of coverage",xlab="Depth of coverage",ylab="Percent coverage", col="blue",type="o",cex=0.6)
	par(new=TRUE)
	plot(percent2,xlim=c(1,nrow(sample2)),ylim=c(0,115),xlab="Depth of coverage",ylab="Percent coverage", col="green",type="o",cex=0.6)
	par(new=TRUE)
	plot(percent3,xlim=c(1,nrow(sample3)),ylim=c(0,115),xlab="Depth of coverage",ylab="Percent coverage", col="red",type="o",cex=0.6)
	par(new=TRUE)
	plot(percent4,xlim=c(1,nrow(sample4)),ylim=c(0,115),xlab="Depth of coverage",ylab="Percent coverage", col="black",type="o",cex=0.6)
	par(new=TRUE)
	plot(percent5,xlim=c(1,nrow(sample5)),ylim=c(0,115),xlab="Depth of coverage",ylab="Percent coverage", col="brown",type="o",cex=0.6)
	legend((nrow(sample1)-40),15,c(samplename1, samplename2, samplename3, samplename4, samplename5), cex=0.7, col=c("blue", "green", "red", "black", "brown"), pch=21, lty=1)
	dev.off()
	}

	else if (length(stdin)==12)
	{
	target=as.integer(stdin[6])
	samplename1=as.character(stdin[7])
	samplename2=as.character(stdin[8])
	samplename3=as.character(stdin[9])
	samplename4=as.character(stdin[10])
	samplename5=as.character(stdin[11])
	samplename6=as.character(stdin[12])
	file1=paste(samplename1,".coverage.out", sep="", collapse=NULL)
	file2=paste(samplename2,".coverage.out", sep="", collapse=NULL)
	file3=paste(samplename3,".coverage.out", sep="", collapse=NULL)
	file4=paste(samplename4,".coverage.out", sep="", collapse=NULL)
	file5=paste(samplename5,".coverage.out", sep="", collapse=NULL)
	file6=paste(samplename6,".coverage.out", sep="", collapse=NULL)
	sample1=as.matrix(read.table(file=file1))
	sample2=as.matrix(read.table(file=file2))
	sample3=as.matrix(read.table(file=file3))
	sample4=as.matrix(read.table(file=file4))
	sample5=as.matrix(read.table(file=file5))
	sample6=as.matrix(read.table(file=file6))
	percent1=(sample1/target)*100
	percent2=(sample2/target)*100
	percent3=(sample3/target)*100
	percent4=(sample4/target)*100
	percent5=(sample5/target)*100
	percent6=(sample6/target)*100
	jpeg(file="coverage.jpeg", width = 1190, height = 1190, quality=100, res=100)
	plot(percent1,xlim=c(1,nrow(sample1)),ylim=c(0,115),main="Coverage across target regions at different depths of coverage",xlab="Depth of coverage",ylab="Percent coverage", col="blue",type="o",cex=0.6)
	par(new=TRUE)
	plot(percent2,xlim=c(1,nrow(sample2)),ylim=c(0,115),xlab="Depth of coverage",ylab="Percent coverage", col="green",type="o",cex=0.6)
	par(new=TRUE)
	plot(percent3,xlim=c(1,nrow(sample3)),ylim=c(0,115),xlab="Depth of coverage",ylab="Percent coverage", col="red",type="o",cex=0.6)
	par(new=TRUE)
	plot(percent4,xlim=c(1,nrow(sample4)),ylim=c(0,115),xlab="Depth of coverage",ylab="Percent coverage", col="black",type="o",cex=0.6)
	par(new=TRUE)
	plot(percent5,xlim=c(1,nrow(sample5)),ylim=c(0,115),xlab="Depth of coverage",ylab="Percent coverage", col="brown",type="o",cex=0.6)
	par(new=TRUE)
	plot(percent6,xlim=c(1,nrow(sample6)),ylim=c(0,115),xlab="Depth of coverage",ylab="Percent coverage", col="violet",type="o",cex=0.6)
	legend((nrow(sample1)-40),15,c(samplename1, samplename2, samplename3, samplename4, samplename5, samplename6), cex=0.7, col=c("blue", "green", "red", "black", "brown", "violet"), pch=21, lty=1)
	dev.off()
	}

	else if (length(stdin)==13)
	{
	target=as.integer(stdin[6])
	samplename1=as.character(stdin[7])
	samplename2=as.character(stdin[8])
	samplename3=as.character(stdin[9])
	samplename4=as.character(stdin[10])
	samplename5=as.character(stdin[11])
	samplename6=as.character(stdin[12])
	samplename7=as.character(stdin[13])
	file1=paste(samplename1,".coverage.out", sep="", collapse=NULL)
	file2=paste(samplename2,".coverage.out", sep="", collapse=NULL)
	file3=paste(samplename3,".coverage.out", sep="", collapse=NULL)
	file4=paste(samplename4,".coverage.out", sep="", collapse=NULL)
	file5=paste(samplename5,".coverage.out", sep="", collapse=NULL)
	file6=paste(samplename6,".coverage.out", sep="", collapse=NULL)
	file7=paste(samplename7,".coverage.out", sep="", collapse=NULL)
	sample1=as.matrix(read.table(file=file1))
	sample2=as.matrix(read.table(file=file2))
	sample3=as.matrix(read.table(file=file3))
	sample4=as.matrix(read.table(file=file4))
	sample5=as.matrix(read.table(file=file5))
	sample6=as.matrix(read.table(file=file6))
	sample7=as.matrix(read.table(file=file7))
	percent1=(sample1/target)*100
	percent2=(sample2/target)*100
	percent3=(sample3/target)*100
	percent4=(sample4/target)*100
	percent5=(sample5/target)*100
	percent6=(sample6/target)*100
	percent7=(sample7/target)*100
	jpeg(file="coverage.jpeg", width = 1190, height = 1190, quality=100, res=100)
	plot(percent1,xlim=c(1,nrow(sample1)),ylim=c(0,115),main="Coverage across target regions at different depths of coverage",xlab="Depth of coverage",ylab="Percent coverage", col="blue",type="o",cex=0.6)
	par(new=TRUE)
	plot(percent2,xlim=c(1,nrow(sample2)),ylim=c(0,115),xlab="Depth of coverage",ylab="Percent coverage", col="green",type="o",cex=0.6)
	par(new=TRUE)
	plot(percent3,xlim=c(1,nrow(sample3)),ylim=c(0,115),xlab="Depth of coverage",ylab="Percent coverage", col="red",type="o",cex=0.6)
	par(new=TRUE)
	plot(percent4,xlim=c(1,nrow(sample4)),ylim=c(0,115),xlab="Depth of coverage",ylab="Percent coverage", col="black",type="o",cex=0.6)
	par(new=TRUE)
	plot(percent5,xlim=c(1,nrow(sample5)),ylim=c(0,115),xlab="Depth of coverage",ylab="Percent coverage", col="brown",type="o",cex=0.6)
	par(new=TRUE)
	plot(percent6,xlim=c(1,nrow(sample6)),ylim=c(0,115),xlab="Depth of coverage",ylab="Percent coverage", col="violet",type="o",cex=0.6)
	par(new=TRUE)
	plot(percent7,xlim=c(1,nrow(sample7)),ylim=c(0,115),xlab="Depth of coverage",ylab="Percent coverage", col="grey50",type="o",cex=0.6)
	legend((nrow(sample1)-40),15,c(samplename1, samplename2, samplename3, samplename4, samplename5, samplename6, samplename7), cex=0.7, col=c("blue", "green", "red", "black", "brown", "violet", "grey50"), pch=21, lty=1)
	dev.off()
	}

	else if (length(stdin)==14)
	{
	target=as.integer(stdin[6])
	samplename1=as.character(stdin[7])
	samplename2=as.character(stdin[8])
	samplename3=as.character(stdin[9])
	samplename4=as.character(stdin[10])
	samplename5=as.character(stdin[11])
	samplename6=as.character(stdin[12])
	samplename7=as.character(stdin[13])
	samplename8=as.character(stdin[14])
	file1=paste(samplename1,".coverage.out", sep="", collapse=NULL)
	file2=paste(samplename2,".coverage.out", sep="", collapse=NULL)
	file3=paste(samplename3,".coverage.out", sep="", collapse=NULL)
	file4=paste(samplename4,".coverage.out", sep="", collapse=NULL)
	file5=paste(samplename5,".coverage.out", sep="", collapse=NULL)
	file6=paste(samplename6,".coverage.out", sep="", collapse=NULL)
	file7=paste(samplename7,".coverage.out", sep="", collapse=NULL)
	file8=paste(samplename8,".coverage.out", sep="", collapse=NULL)
	sample1=as.matrix(read.table(file=file1))
	sample2=as.matrix(read.table(file=file2))
	sample3=as.matrix(read.table(file=file3))
	sample4=as.matrix(read.table(file=file4))
	sample5=as.matrix(read.table(file=file5))
	sample6=as.matrix(read.table(file=file6))
	sample7=as.matrix(read.table(file=file7))
	sample8=as.matrix(read.table(file=file8))	
	percent1=(sample1/target)*100
	percent2=(sample2/target)*100
	percent3=(sample3/target)*100
	percent4=(sample4/target)*100
	percent5=(sample5/target)*100
	percent6=(sample6/target)*100
	percent7=(sample7/target)*100
	percent8=(sample8/target)*100
	jpeg(file="coverage.jpeg", width = 1190, height = 1190, quality=100, res=100)
	plot(percent1,xlim=c(1,nrow(sample1)),ylim=c(0,115),main="Coverage across target regions at different depths of coverage",xlab="Depth of coverage",ylab="Percent coverage", col="blue",type="o",cex=0.6)
	par(new=TRUE)
	plot(percent2,xlim=c(1,nrow(sample2)),ylim=c(0,115),xlab="Depth of coverage",ylab="Percent coverage", col="green",type="o",cex=0.6)
	par(new=TRUE)
	plot(percent3,xlim=c(1,nrow(sample3)),ylim=c(0,115),xlab="Depth of coverage",ylab="Percent coverage", col="red",type="o",cex=0.6)
	par(new=TRUE)
	plot(percent4,xlim=c(1,nrow(sample4)),ylim=c(0,115),xlab="Depth of coverage",ylab="Percent coverage", col="black",type="o",cex=0.6)
	par(new=TRUE)
	plot(percent5,xlim=c(1,nrow(sample5)),ylim=c(0,115),xlab="Depth of coverage",ylab="Percent coverage", col="brown",type="o",cex=0.6)
	par(new=TRUE)
	plot(percent6,xlim=c(1,nrow(sample6)),ylim=c(0,115),xlab="Depth of coverage",ylab="Percent coverage", col="violet",type="o",cex=0.6)
	par(new=TRUE)
	plot(percent7,xlim=c(1,nrow(sample7)),ylim=c(0,115),xlab="Depth of coverage",ylab="Percent coverage", col="grey50",type="o",cex=0.6)
	par(new=TRUE)
	plot(percent8,xlim=c(1,nrow(sample8)),ylim=c(0,115),xlab="Depth of coverage",ylab="Percent coverage", col="tomato",type="o",cex=0.6)
	legend((nrow(sample1)-40),15,c(samplename1, samplename2, samplename3, samplename4, samplename5, samplename6, samplename7,samplename8), cex=0.7, col=c("blue", "green", "red", "black", "brown", "violet", "grey50", "tomato"), pch=21, lty=1)
	dev.off()
	}

	else
	{
	print ("Please enter the sample names")
	}
}
