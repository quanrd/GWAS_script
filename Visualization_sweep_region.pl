#!/usr/bin/perl -w
use Getopt::Long;
my ($Fst,$Pi_group1,$Pi_group12);
GetOptions
(
    "Fst:s" => \$Fst,
	"Pi_group1:s" => \$Pi_group1,
	"Pi_group2:s" => \$Pi_group2,
);
sub usage
{
        die qq/
Usage: perl $0 [options]

Options:
        -Fst        <s> : Fst generated by vcftools
        -Pi_group1  <s> : Pi generated by vcftools
        -Pi_group2  <s> : Pi generated by vcftools
\n/;
}
if (!defined $Fst ||  !defined $Pi_group1 || !defined $Pi_group2 )
{    &usage();       }

open (OUT,">Rscript.r");
print OUT "library(qqman)\n";
print OUT "fst=read.table(\"$Fst\",header = T)"."\n";
print OUT "group1=read.table(\"$Pi_group1\",header = T,sep = \"\\t\")"."\n";
print OUT  "group2=read.table(\"$Pi_group2\",header = T,sep = \"\\t\")"."\n";
print OUT  'pdf("Fst_all_26.pdf")'."\n";
print OUT  'top_fst_5percentage=fst[fst$MEAN_FST > quantile(fst$MEAN_FST,prob=1-5/100),]'."\n";
print OUT  'write.table(top_fst_5percentage,"Fst_top_5%.txt",sep = "\t",quote = F,row.names = F)'."\n";
print OUT  'top_fst_1percentage=fst[fst$MEAN_FST > quantile(fst$MEAN_FST,prob=1-1/100),]'."\n";
print OUT  'write.table(top_fst_1percentage,"Fst_top_1%.txt",sep = "\t",quote = F,row.names = F)'."\n";
print OUT  'fstsubset<-fst[complete.cases(fst),]'."\n";
print OUT  'SNP<-c(1:(nrow(fstsubset)))'."\n";
print OUT  'mydf<-data.frame(SNP,fstsubset)'."\n";
print OUT  'mydf$CHROM = as.numeric(mydf$CHROM)'."\n";
print OUT  'manhattan(mydf,chr="CHROM",bp="BIN_START",p="MEAN_FST",snp="SNP",logp=FALSE,ylab="Mean Fst",col=c("blue","red"),)'."\n";
print OUT  'dev.off()'."\n";
print OUT  'pdf("Fst_Asub_13.pdf")'."\n";
print OUT  'mydfA=subset(mydf,CHROM <14)'."\n";
print OUT  'manhattan(mydfA,chr="CHROM",bp="BIN_START",p="MEAN_FST",snp="SNP",logp=FALSE,ylab="Mean Fst",col=c("blue","red"))'."\n";
print OUT  'dev.off()'."\n";
print OUT  'pdf("Fst_Dsub_13.pdf")'."\n";
print OUT  'mydfD=subset(mydf,CHROM > 13)'."\n";
print OUT  'manhattan(mydfD,chr="CHROM",bp="BIN_START",p="MEAN_FST",snp="SNP",logp=FALSE,ylab="Mean Fst",col=c("blue","red"))'."\n";
print OUT  'dev.off()'."\n";
print OUT  'group1$ID= paste(group1$CHROM,group1$BIN_START,sep = "_")'."\n";
print OUT  'group2$ID= paste(group2$CHROM,group2$BIN_START,sep = "_")'."\n";
print OUT  'pi<-merge(group2,group2,by="ID")'."\n";
print OUT  'mydf_for_pi=subset(pi,pi$PI.y>0 && pi$PI.x >0)'."\n";
print OUT  'mydf_for_pi$piXY= pi$PI.x/pi$PI.y'."\n";
print OUT  'pdf("Pi_all_26.pdf")'."\n";
print OUT  'mydf_for_pi$CHROM.x=as.numeric(mydf_for_pi$CHROM.x)'."\n";
print OUT  'manhattan(mydf_for_pi,chr="CHROM.x",bp="BIN_START.x",p="piXY",snp="ID",logp=FALSE,ylab="Mean pi",col=c("blue","red"))'."\n";
print OUT  'dev.off()'."\n";
print OUT  'pdf("Pi_Asub_13.pdf")'."\n";
print OUT  'mydf_for_pi$CHROM.x=as.numeric(mydf_for_pi$CHROM.x)'."\n";
print OUT  'mydf_for_pi_A=subset(mydf_for_pi,mydf_for_pi$CHROM.x <14)'."\n";
print OUT  'manhattan(mydf_for_pi_A,chr="CHROM.x",bp="BIN_START.x",p="piXY",snp="ID",logp=FALSE,ylab="Mean pi",col=c("blue","red"))'."\n";
print OUT  'dev.off()'."\n";
print OUT  'pdf("Pi_Dsub_13.pdf")'."\n";
print OUT  'mydf_for_pi_D=subset(mydf_for_pi,mydf_for_pi$CHROM.x >13)'."\n";
print OUT  'manhattan(mydf_for_pi_D,chr="CHROM.x",bp="BIN_START.x",p="piXY",snp="ID",logp=FALSE,ylab="Mean pi",col=c("blue","red"))'."\n";
print OUT  'dev.off()'."\n";
print OUT  'pi_table=subset(mydf_for_pi,select = c("CHROM.x","BIN_START.x","N_VARIANTS.x","N_VARIANTS.y","piXY"))'."\n";
print OUT  'pi_top_5percentage=fst[pi_table$piXY > quantile(pi_table$piXY,prob=1-5/100),]'."\n";
print OUT  'write.table(top_fst_5percentage,"Pi_top_5%.txt",sep = "\t",quote = F,row.names = F)'."\n";
print OUT  'pi_top_1percentage=fst[pi_table$piXY > quantile(pi_table$piXY,prob=1-1/100),]'."\n";
print OUT  'write.table(top_fst_1percentage,"Pi_top_1%.txt",sep = "\t",quote = F,row.names = F)'."\n";
system("Rscript ./Rscript.r") ;
system("rm ./Rscript.r") ;
open (OUT2,">Rscript2.r");
print OUT2 "library(ggplot2)\n";
print OUT2  "pdf(\"Selection.pdf\",width = 12,height = 4)\n";
print OUT2  "ggplot(mtcars, aes(wt, mpg)) +\n";
$start=0;
while (<DATA>) {
@a=split("\t",$_);
$end= $start+$a[1]/1000000;
print OUT2 "annotate(\"rect\", xmin =$start, xmax = $end, fill=\"yellow\",ymin = 10, ymax = 20, alpha = .6) +\n";
print OUT2  "annotate(\"rect\", xmin =$start, xmax = $end, fill=\"yellow\",ymin = 23, ymax = 33, alpha = .6) +\n";
print OUT2  "annotate(\"rect\", xmin =$start, xmax = $end, fill=\"blue\",ymin = 36, ymax = 46, alpha = .6) +\n";
print OUT2  "annotate(\"rect\", xmin =$start, xmax = $end, fill=\"blue\",ymin = 49, ymax = 59, alpha = .6) +\n";
$text_pos= $start/2+$end/2;
print OUT2  "annotate(\"text\", x = $text_pos, y = 5, label = c(\"$a[0]\"))+\n";
$hash{$a[0]}=$start;
$start=$end+10;
}
open (IN2,"Fst_top_5%.txt")or die ("Can not open Fst_top_5%"); 
<IN2>;
while (<IN2>) {
@b=split("\t",$_);
$Signal_min= $hash{$b[0]}+$b[1]/1000000;
$Signal_max= $hash{$b[0]}+$b[1]/1000000+5;
print OUT2  "annotate(\"rect\", xmin =$Signal_min, xmax = $Signal_max, fill=\"black\",ymin = 10, ymax = 20) +\n"; #LGZ
}
close IN2;
open (IN3,"Fst_top_1%.txt")or die ("Can not open Fst_top_1%"); 
<IN3>;
while (<IN3>) {
@b=split("\t",$_);
$Signal_min= $hash{$b[0]}+$b[1]/1000000;
$Signal_max= $hash{$b[0]}+$b[1]/1000000+5;
print OUT2  "annotate(\"rect\", xmin =$Signal_min, xmax = $Signal_max, fill=\"black\",ymin = 23, ymax = 33) +\n"; #DXM
}
close IN3;
open (IN4,"Pi_top_5%.txt")or die ("Can not open Pi_top_5%"); 
<IN4>;
while (<IN4>) {
@b=split("\t",$_);
$Signal_min= $hash{$b[0]}+$b[1]/1000000;
$Signal_max= $hash{$b[0]}+$b[1]/1000000+5;
print OUT2  "annotate(\"rect\", xmin =$Signal_min, xmax = $Signal_max, fill=\"black\",ymin = 36, ymax = 46) +\n"; 
}
close IN4;
open (IN5,"Pi_top_1%.txt")or die ("Can not open Pi_top_1%"); 
<IN5>;
while (<IN5>) {
@b=split("\t",$_);
$Signal_min= $hash{$b[0]}+$b[1]/1000000;
$Signal_max= $hash{$b[0]}+$b[1]/1000000+5;
print OUT2  "annotate(\"rect\", xmin =$Signal_min, xmax = $Signal_max, fill=\"black\",ymin = 49, ymax = 59) +\n"; 
}
close IN5;
print OUT2  "annotate(\"text\", x = -100, y = 15, label = c(\"5%FST\"))+\n";
print OUT2  "annotate(\"text\", x = -100, y = 28, label = c(\"1%FST\"))+\n";
print OUT2  "annotate(\"text\", x = -100, y = 41, label = c(\"5%Pi\"))+\n";
print OUT2  "annotate(\"text\", x = -100, y = 54, label = c(\"1%Pi\"))+\n";
print OUT2  "theme_bw()+theme(axis.text = element_blank())+theme(panel.grid=element_blank())+xlab(\"\")+ylab(\"\")\n";
print OUT2  "dev.off()\n";
system("Rscript ./Rscript2.r") ;
system("rm ./Rscript2.r") ;


__DATA__
A01	118174371
A02	108272889
A03	111586618
A04	87703368
A05	110845161
A06	126488190
A07	96598283
A08	125056055
A09	83216487
A10	115096118
A11	121376521
A12	107588319
A13	110367549
D01	64698102
D02	69777850
D03	53896199
D04	56935404
D05	63929679
D06	65459843
D07	58417686
D08	69080421
D09	52000373
D10	66881427
D11	71358197
D12	61693100
D13	64447585
