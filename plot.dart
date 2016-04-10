import 'dart:math';
import 'dart:html';
import 'dart:svg';

import "package:intl/intl.dart"; //For number formating

int axisWidth = 3;
int axisOffsetX = 25;
int axisOffsetY = 17 + axisWidth;

var nf0 = new NumberFormat(".0#", "en_US");
var nf1 = new NumberFormat("0.0", "en_US");

List<int> getPlotRangeY(List<double> yVals0, List<double> yVals1) {
	double m0 = yVals0.reduce(max);
	double m1 = yVals1.reduce(max);

	double m = max(m0,m1);

	if(m>20) {
		return [0,20];
	}
	try { 
		return [0, m.ceil()];
	}
	catch (e) {
		return [0,20];
	}
}

//Assumes that you're painting two functions, assumes that there is no scaling for the x-axis
void paintPlot(SvgElement svgE, List<double> xVals, List<double> yVals0, List<double> yVals1, List<double> scaleY) {
	int height = svgE.clientHeight;
	int width = svgE.clientWidth;

	String redStyle = "stroke:rgb(255,0,0);stroke-width:2";
	String blueStyle = "stroke:rgb(0,0,255);stroke-width:2";

	List<double> pRangeY = getPlotRangeY(yVals0,yVals1);
	
	double scaleY = 1/pRangeY[1];

	svgE.children.clear();
	drawAxes(svgE,[[0,1],pRangeY]);
	plotConnectedPoints(svgE,xVals,yVals0,[1,scaleY],redStyle);
	plotConnectedPoints(svgE,xVals,yVals1,[1,scaleY],blueStyle);
}

void plotConnectedPoints(SvgElement svgE, List<double> xVals, List<double> yVals, List<double> scale, String style) {
	for(int i=0; i<xVals.length-1; i++) {
		addLine(svgE,[scale[0]*xVals[i],scale[1]*yVals[i]],[scale[0]*xVals[i+1],scale[1]*yVals[i+1]],style);
	}
}

//Assumes that you're only plotting the first quadrant
void drawAxes(SvgElement svgE, List<List<double>> plotRange) {
	int height = svgE.clientHeight;
	int width = svgE.clientWidth;

	int axisHeightY = height - axisOffsetY;
	int axisLengthX = width - axisOffsetX;

	int pRangeX = [plotRange[0][0].floor(), plotRange[0][1].floor()];
	int pRangeY = [plotRange[1][0].floor(), plotRange[1][1].floor()];

	//Axes
	String thick = "stroke:rgb(0,0,0);stroke-width:"+axisWidth.toString();
	addLine(svgE,[0,0],[1,0],thick);
	addLine(svgE,[0,0],[0,1],thick);

	//Vertical light grey lines
	String lightGrey = "stroke:rgb(169,169,169);stroke-width:1";
	addLine(svgE, [.25,0], [.25,1], lightGrey);
	addLine(svgE, [.5,0], [.5,1], lightGrey);
	addLine(svgE, [.75,0], [.75,1], lightGrey);
	addLine(svgE, [1,0], [1,1], lightGrey);

	//Horizontal light grey lines
	addLine(svgE, [0,.25], [1,.25], lightGrey);
	addLine(svgE, [0,.5], [1,.5], lightGrey);
	addLine(svgE, [0,.75], [1,.75], lightGrey);
	addLine(svgE, [0,1], [1,1], lightGrey);

	//x-axis labels
	int numTicks = 4;
	double step = (pRangeX[1]-pRangeX[0])/numTicks;
	for (double x=0; x<=1; x+=.25) {
		addTextBelowX(svgE,[x,0],pRangeX[0]+x*numTicks*step);
	}

	//y-axis labels
	numTicks = 4;
	step = (pRangeY[1]-pRangeY[0])/numTicks;
	for (double x=0; x<=1; x+=.25) {
		addTextLeftY(svgE,[0,x],pRangeY[0]+x*numTicks*step);
	}
}

void addTextLeftY(svgElement svgE, List<double> p, double n) {
	int height = svgE.clientHeight;
	int width = svgE.clientWidth;
	p = pointToCanvas(p,width,height);
	p[0] -= axisOffsetX - 9;
	p[1] += 5;

	//addTextAbsolute(svgE, p, n.toString());
	String s = n.toString();
	if (n<1) {
		s = nf0.format(n);
	}
	else {
		s = nf1.format(n);
	}
	addTextAbsolute(svgE, p, s);
}

void addTextBelowX(SvgElement svgE, List<double> p, double n) {
	int height = svgE.clientHeight;
	int width = svgE.clientWidth;
	p = pointToCanvas(p,width,height);
	p[1] += axisOffsetY;

	addTextAbsolute(svgE, p, n.toString());
}

void addTextAbsolute(SvgElement svgE, List<double> p, String s) {
	TextElement tLabel = new TextElement();
	tLabel.setAttribute("text-anchor","middle");
	tLabel.setAttribute("x",p[0].toString());
	tLabel.setAttribute("y",p[1].toString());
	tLabel.appendText(s);
	svgE.children.add(tLabel);
}

void addLine(SvgElement svgE, List<double> p0, List<double> p1, String styleString) {
	int height = svgE.clientHeight;
	int width = svgE.clientWidth;

	p0 = pointToCanvas(p0,width,height);
	p1 = pointToCanvas(p1,width,height);

	LineElement line = new LineElement();
	line.setAttribute("x1",p0[0].toString());
	line.setAttribute("y1",p0[1].toString());
	line.setAttribute("x2",p1[0].toString());
	line.setAttribute("y2",p1[1].toString()); 
	line.setAttribute("style",styleString);
	svgE.children.add(line);
}

List<int> pointToCanvas(List<double> point, double width, double height) {
	int outX = axisOffsetX + axisWidth + point[0]*(width-2*axisOffsetX-axisWidth);
	int yBuffer = 5; //An additional buffer at the top b/c the y-labels spill over
	int outY = height - axisOffsetY - axisWidth - point[1]*(height-axisOffsetY-yBuffer-axisWidth);

	return [outX, outY];
}