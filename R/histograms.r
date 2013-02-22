btf <- read.csv("~/Desktop/backtofail.csv",row.names=NULL)
btf.ff <- btf[which(btf$run=='FF'),]
btf.ibs <- btf[which(btf$run=='IBS'),]
btf.abs <- btf[which(btf$run=='ABS'),]
btf.wdeg <- btf[which(btf$run=='WDeg'),]
btf.wh <- hist(btf.wdeg$time,nclass=20)
btf.ah <- hist(btf.abs$time,nclass=20)
btf.ih <- hist(btf.ibs$time,nclass=20)
plot(btf.wh,col=rgb(1,0,0,1/4),
	xlim=c(0,max(btf.wh$breaks,btf.ih$breaks,btf.ah$breaks)),
	ylim=c(0,max(btf.wh$counts,btf.ih$counts,btf.ah$counts)),
	main="Comparative Histograms (WDeg/IBS/ABS) + BTF")
plot(btf.ih,col=rgb(0,0,1,1/4),add=T)
plot(btf.ah,col=rgb(0,1,0,1/4),add=T)


nobtf <- read.csv("~/Desktop/nobacktofail.csv",row.names=NULL)
nobtf.ff <- nobtf[which(nobtf$run=='FF'),]
nobtf.ibs <- nobtf[which(nobtf$run=='IBS'),]
nobtf.abs <- nobtf[which(nobtf$run=='ABS'),]
nobtf.wdeg <- nobtf[which(nobtf$run=='WDeg'),]
nobtf.wh <- hist(nobtf.wdeg$time,nclass=20)
nobtf.ah <- hist(nobtf.abs$time,nclass=20)
nobtf.ih <- hist(nobtf.ibs$time,nclass=20)
plot(nobtf.wh,col=rgb(1,0,0,1/4),
	xlim=c(0,max(nobtf.wh$breaks,nobtf.ih$breaks,nobtf.ah$breaks)),
	ylim=c(0,max(nobtf.wh$counts,nobtf.ih$counts,nobtf.ah$counts)),
	main="Comparative Histograms (WDeg/IBS/ABS)")
plot(nobtf.ih,col=rgb(0,0,1,1/4),add=T)
plot(nobtf.ah,col=rgb(0,1,0,1/4),add=T)


plot(btf.ah,col=rgb(1,0,0,1/4),xlim=c(0,max(nobtf.ah$breaks,btf.ah$breaks)),
	main="Comparative Histograms (BTF ON/OFF) + ABS")
plot(nobtf.ah,col=rgb(0,0,1,1/4),add=T)
