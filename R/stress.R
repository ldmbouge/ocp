pdf(file="~/work/Publications/CP13a/stress-b0.pdf",width=5,height=3,pointsize=10)
f <- doItLimit('~/work/Publications/CP13a/stress-b0.csv',"Nested Limits\nEmpty Model(|X|=16,|D|=2)")
coef(f)[2] / coef(f)[1] * 100
dev.off()

pdf(file="~/work/Publications/CP13a/stress-b1.pdf",width=5,height=3,pointsize=10)
f <- doItFolio('~/work/Publications/CP13a/stress-b1.csv',"Nested Portfolio\nEmpty Model(|X|=16,|D|=2)")
coef(f)[2] / coef(f)[1] * 100
dev.off()

pdf(file="~/work/Publications/CP13a/stress-b2.pdf",width=5,height=3,pointsize=10)
f <- doItLimit('~/work/Publications/CP13a/stress-b2.csv',"Nested Limits\nQueens(12)")
coef(f)[2] / coef(f)[1] * 100
dev.off()

pdf(file="~/work/Publications/CP13a/stress-b3.pdf",width=5,height=3,pointsize=10)
f <- doItFolio('~/work/Publications/CP13a/stress-b3.csv',"Nested Portfolio\nQueens(12)")
coef(f)[2] / coef(f)[1] * 100
dev.off()


doItLimit <- function(fname,title) {
	d <- read.csv(fname)
	b0 <- ddply(d, .(found),summarise,mean=mean(cpu),sd=sd(cpu),low=mean(cpu)-sd(cpu),up=mean(cpu)+sd(cpu))
	errbar(b0$found,b0$mean,b0$low,b0$up,ylab="Time (msec)",xlab="Nesting")	
	abline(lm(b0$mean ~ b0$found),col="red",lwd=2)
	y <- floor(max(b0$mean)/100) * 100
	x <- 0
	text(x,y,title,pos=4)
	b1 <- b0[,c("mean","sd")]
	nn <- paste(strsplit(fname, "\\.")[[1]][1],"_summary.csv",sep='')
	write.csv(b1,nn)
	return (lm(b0$mean ~ b0$found))
}

doItFolio <- function(fname,title) {
	d <- read.csv(fname)
	b0 <- ddply(d, .(found),summarise,mean=mean(cpu),sd=sd(cpu),low=mean(cpu)-sd(cpu),up=mean(cpu)+sd(cpu))
	b0$mean <- b0$mean / (b0$found + 1)
	b0$sd  <- b0$sd / (b0$found + 1)
	b0$low <- b0$mean - b0$sd
	b0$up <- b0$mean + b0$sd
	b0$found <- (b0$found + 1)
	errbar(b0$found,b0$mean,b0$low,b0$up,ylab="Time (msec)",xlab="Nesting")
	abline(lm(b0$mean ~ b0$found),col="red",lwd=2)
	y <- floor(max(b0$mean)/1) * 1 + 50
	x <- 0
	text(x,y,title,pos=4)
	b1 <- b0[,c("mean","sd")]
	nn <- paste(strsplit(fname, "\\.")[[1]][1],"_summary.csv",sep='')
	write.csv(b1,nn)
	return (lm(b0$mean ~ b0$found))
}

d <- read.csv('~/Desktop/stress-b0.csv')
b0 <- ddply(d, .(found),summarise,mean=mean(cpu),sd=sd(cpu),low=mean(cpu)-sd(cpu),up=mean(cpu)+sd(cpu))
ov <- data.frame(cbind(b0$mean - b0[1,2],b0$low- b0[1,2],b0$up - b0[1,2]))
errbar(seq(0,20),ov$X1,ov$X2,ov$X3,ylab="Time (msec)",xlab="Nesting")
abline(lm(ov$X1 ~ seq(0,20)),col="red",lwd=2)


d <- read.csv('~/Desktop/stress-b1.csv')
b0 <- ddply(d, .(found),summarise,mean=mean(cpu),sd=sd(cpu),low=mean(cpu)-sd(cpu),up=mean(cpu)+sd(cpu))
b0$mean <- b0$mean / (b0$found + 1)
b0$sd  <- b0$sd / (b0$found + 1)
b0$low <- b0$mean - b0$sd
b0$up <- b0$mean + b0$sd
b0$found <- (b0$found + 1)
errbar(b0$found,b0$mean,b0$low,b0$up,ylab="Time (msec)",xlab="Nesting")
abline(lm(b0$mean ~ b0$found),col="red",lwd=2)
