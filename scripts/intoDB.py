#!/usr/bin/python
# Filename intoDB.py

import subprocess
import os
import sys
import json
import calendar
import time
import datetime
import platform, re
import sqlite3

version = '0.1'

def dict_factory(cursor, row):
    d = {}
    for idx, col in enumerate(cursor.description):
        d[col[0]] = row[idx]
    return d

def get_processor_name():
	p = sys.platform
	if p == 'win32':
		return platform.processor()
	elif p == 'darwin':
		command ="/usr/sbin/sysctl -n machdep.cpu.brand_string"
		cc =  subprocess.Popen(('/usr/sbin/sysctl','-n','machdep.cpu.brand_string'),stdout=subprocess.PIPE)
		cc.wait()
		return cc.stdout.read().strip()
	elif p == 'linux':
		command = "cat /proc/cpuinfo"
		all_info = subprocess.check_output(command, shell=True).strip()
		for line in allInfo.split("\n"):
			if "model name" in line:
				return re.sub( ".*model name.*:", "", line,1)
	return ""

def getSHA1():
	cmd = "git log|head -1|cut -c7-"
	task = subprocess.Popen(cmd, shell=True, stdout=subprocess.PIPE)
	result = task.stdout.read()
	assert task.wait() == 0
	#print "SHA1:" + result
	return result.rstrip().lstrip()

class Collect:
	def __init__(self):
		self.home = os.environ['HOME']
		self.pwd = os.getcwd()
		filename = 'stats.db'
		if os.path.isfile(filename):			
			self.db = sqlite3.connect(filename)
		else:
			self.db = sqlite3.connect(filename)
			c = self.db.cursor()
			c.execute("create table run(pkey integer primary key,date text,machine int,sha1 text)")
			c.execute("create table bench (runid integer,bench text,method text,rand int,threads int,size int,nbsol int,rrate float,nfail int,nchoice int,nprop int,cpu float,wc float,mused float,mpeak float,rc int,foreign key(runid) references run(pkey))")
			c.execute("create table machine(id integer primary key,host text,os text,distrib text,cpu float)")
			c.execute("create index benchIx on bench (runid)")
			c.execute("create index benchName on bench(bench)")
			self.db.commit()						

		if os.path.exists('results.json'):
			self.all = open('results.json','r')
			self.ab  = json.loads(self.all.read())
			self.all.close()
		else:
			self.ab = {}

	def loadINDB(self):
		nv = datetime.datetime.today()
		sDate = nv.strftime('%Y%m%d')
		sTime = nv.strftime('%H%M%S')
		sha1 = getSHA1()
		c = self.db.cursor()
		machine = self.platform(c)
		c.execute("insert into run(date,machine,sha1) values (?,?,?) ",(sDate + ' - ' + sTime,machine,sha1))		
		runid = c.lastrowid
		self.dumpTests(c,runid)
		self.db.commit()
		return runid

	def platform(self,cursor):
		h  = platform.node()
		osd = os.uname()
		pn = get_processor_name()
		parts = pn.split('@')
		cursor.execute("select * from machine where host = '%s'" % h)
		row = cursor.fetchone()
		if row == None:
			cursor.execute("insert into machine(host,os,distrib,cpu) values (?,?,?,?)",(h,os.name,osd[3],float(parts[1][:-3])*1000.0))
			return  cursor.lastrowid
		else:
			return row[0]

	def dumpTests(self,cursor,theID):
		for key in self.ab:
			self.dumpTest(cursor,key,theID)

	def dumpTest(self,cursor,key,theRunID):
		bench = self.ab[key]
		if bench['rc']==0:
			if 'method' in bench.keys():
				av = (theRunID,key,bench['method'],bench['randomized'],
					bench['threads'],bench['size'],bench['found'],bench['rrate'],
					bench['nfail'],bench['nchoice'],bench['nprop'],bench['cpu'],
					bench['wc'],bench['mused'],bench['mpeak'],bench['rc']
			  	)
			else:
				av = (theRunID,key,'','',0,0,0,0.0,0,0,0,0,0,0,0,0)	
		else:
			av = (theRunID,key,'','',0,0,0,0.0,0,0,0,0,0,0,0,0)
		cursor.execute("insert into bench(runid,bench,method,rand,threads,size,nbsol,rrate,nfail,nchoice,nprop,cpu,wc,mused,mpeak,rc) values (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)",av)

	def makeMarkdown(self,runID,useHTMLHeader):
		of = open('summary.md','w')
		if useHTMLHeader:
			of.write("<head>\n<link rel=\"stylesheet\" type=\"text/css\" href=\"espresso.css\">\n</head>\n")		
		c = self.db.cursor()
		c.execute("select pkey,date,sha1,host,os,distrib,cpu from run,machine where run.machine=machine.id AND run.pkey= {0}".format(runID))
		row = c.fetchone()
		#print "DATETIME:" + row[1]
		year = row[1][:4]
		month = row[1][4:6]
		day   = row[1][6:8]
		hour   = row[1][11:13]
		minute = row[1][13:15]
		sec    = row[1][15:17]
		of.write("# Summary for {0}/{1}/{2} @ {3}:{4}:{5}\n".format(day,month,year,hour,minute,sec))
		of.write("##Machine {0}\n- Flavor\t = {1}\n- OS\t={2}\n- Distrib\t={3}\n- CPU\t={3}Mhz\n\n".format(row[3],row[4],row[5],row[6]))
		of.write("SHA1 = {0}\n\n".format(row[2]))
		c.execute("select * from bench where runid={0} order by bench ASC".format(runID))
		of.write("bench | method | threads | size | nbSol | nchoice | cpu(s) | wc(s) | mused(Kb) | mpeak(Kb) | status \n")
		of.write("|-----|--------|---------|------|-------|--------:|----:|---:|------:|------:|--------|\n")
		rn = 0
		ar = c.fetchall()
		for r in ar:
			#print r
			bn = r[1].split(' ')
			#print bn
			of.write("[{0:<20}] [{1}]".format(bn[0],rn) +
			 " | {2:<4} | {4:<2} | {5:>4} | {6:>5} | {9:>7} | {11:>10} | {12:>7} | {13:.2f} | {14:.2f} | {15} \n".format(*r))
			rn += 1
		rn = 0
		of.write("\n\n")
		for r in ar:
			bn = r[1].split(' ')
			of.write("[{0}]: fragment.html#chart_{1}_{2}_{3}_{4}\n".format(rn,bn[0],r[4],r[3],r[2]))
			rn += 1
		of.close()

	def latestMarkDown(self,useHTMLHeader):
		c = self.db.cursor()
		c.execute("select max(pkey) from run")
		row = c.fetchone()
		lastRunID = row[0]
		self.makeMarkdown(lastRunID,useHTMLHeader)

	def makeHTMLPage(self,out,w,h):
		out.write("""<html><head><script type="text/javascript" src="https://www.google.com/jsapi"></script>
			<style media="screen" type="text/css">
#container { width: 1200px; }
.col1 { width: 600px; float: left; }
.col2 { width: 600px; float: left; }
</style></head>""")
		out.write("<body><div id=\"container\">\n")
		self.db.row_factory = dict_factory
		c  = self.db.cursor()
		c.execute("select distinct bench,size,threads,method from bench order by bench asc")
		for r in c.fetchall():
			print r
			print '--------------------------------------------------------------------------------------------------'		
			seg = r['bench'].split(' ')
			name = seg[0]
			size = r['size']			
			self.makeGraph(name + '%',size,r['threads'],r['method'],out,w,h)
#		self.makeGraph('queensAC %',12,out,w,h)
#		self.makeGraph('sport %',0,out,w,h)
		out.write("</div></body>\n")
		out.write("""</html>\n""")

	def makeGraph(self,name,sz,threads,method,out,w,h):
		cleanName = name.strip('%').strip() + '_' + str(sz) + '_' + str(threads) + '_' + method
		out.write("""<div class="col1"><script type="text/javascript">
      google.load("visualization", "1", {packages:["corechart"]});
      google.setOnLoadCallback(drawChart_""" + cleanName + """);
      function drawChart_""" + cleanName + """() {
        var data = google.visualization.arrayToDataTable(
        	""")
		out.write("[['date','cpu','wc'],\n")
		self.db.row_factory = dict_factory
		c = self.db.cursor()
		query = "select bench,wc,cpu,date,size,threads,method from bench,run where bench.runid=run.pkey AND bench like '{0}' AND size={1} AND threads={2} AND method like '{3}' order by runid asc".format(name,sz,threads,method)
		c.execute(query)
		for r in c.fetchall():
			print r
			wc = r['wc']
			cpu = r['cpu']
			stamp = r['date']
			year = stamp[:4]
			month = stamp[4:6]
			day   = stamp[6:8]
			hour   = stamp[11:13]
			minute = stamp[13:15]
			sec    = stamp[15:17]
			out.write("['{0}/{1}/{2} - {3}:{4}',{5},{6}],\n".format(day,month,year,hour,minute,cpu,wc))
		out.write("]);\n")
		out.write("var options = { title: 'Benchmark: " + "{0} ({1}) (Threads={2}) (Heur={3})".format(name.strip('%'),sz,threads,method) + "'};")
		out.write("""
        var chart = new google.visualization.LineChart(document.getElementById('chart_div_""" + cleanName + """'));
        chart.draw(data, options);
      }
    </script>""")
		out.write("<a name=\"chart_{0}\"><div id=\"chart_div_{0}\" style=\"width: {1}px; height: {2}px;\"></div></a></div>\n".format(cleanName,w,h))


if __name__ == '__main__':
	c = Collect()
	#c.loadINDB()
	c.latestMarkDown(False)
	out = open('fragment.html','w')
	c.latestMarkDown(True)
	c.makeHTMLPage(out,600,200)

