import 'dart:math';
import 'dart:html';
import 'dart:svg';

import "package:intl/intl.dart"; //For number formating

import 'bandits.dart';
import 'plot.dart';

ButtonElement stepButton;

Network network;
int numAgents = 5;
List<BetaAgent> agents;
List<Machine> machines;

var nfAlphaBeta = new NumberFormat("0.0", "en_US");
var nfExp = new NumberFormat(".0000", "en_US");

void main() {
	machines = [ new Machine(.5), new Machine(.51) ];

	agents = [];
	for (int i=0; i<numAgents; i++) {
		agents.add(new BetaAgent());
	}

	// int graph = makeCompleteGraph(numAgents);
	List<List<int>> graph = makeStarGraph(numAgents);
	network = new Network(agents, machines, graph);

	paintNetwork(true);
	updateDisplay();

	stepButton = querySelector('#stepButton');
  	stepButton.onClick.listen(stepButtonClicked);

  	querySelector('#resetButton').onClick.listen(resetButtonClicked);

  	querySelector('#star_radio').onClick.listen(switchToStar);
  	querySelector('#complete_radio').onClick.listen(switchToComplete);

  	querySelector('#red_arm_p').onInput.listen(changeMachine0);
  	querySelector('#blue_arm_p').onInput.listen(changeMachine1);
}

void changeMachine0(Event e) {
	double p = .5;
	try {
		p = double.parse(e.target.value);
	} 
	catch (ex) {
		print(ex);
	}
	machines[0] = new Machine(p);
}

void changeMachine1(Event e) {
	double p = .51;
	try {
		p = double.parse(e.target.value);
	} 
	catch (ex) {
		print(ex);
	}
	machines[1] = new Machine(p);
}

void switchToStar(Event e) {
	List<List<int>> starGraph = makeStarGraph(numAgents);
	network.adjMatrix = starGraph;
	paintNetwork(true);
}

void switchToComplete(Event e) {
	List<List<int>> completeGraph = makeCompleteGraph(numAgents);
	network.adjMatrix = completeGraph;
	paintNetwork(false);
}

void resetButtonClicked(Event e) {
	List<double> alpha = [0,4];
	List<double> beta = [0,4];

	// alpha[0] = querySelector('#alpha_lower_text').value;

	alpha[0] = double.parse(querySelector('#alpha_lower_text').value);
	alpha[1] = double.parse(querySelector('#alpha_upper_text').value);
	beta[0] = double.parse(querySelector('#beta_lower_text').value);
	beta[1] = double.parse(querySelector('#beta_upper_text').value);

	for (BetaAgent agent in agents) {
		agent.resetFromInterval(alpha,beta);
	}

	updateDisplay();
}

void stepButtonClicked(Event e) {
	List<int> acts = network.getActs();
	List<int> payouts = network.getPayouts(acts);

	network.step(acts,payouts);

	updateDisplay();
}

void updateDisplay() {
	updateDisplayForAgent(0);
	updateDisplayForAgent(1);
	updateDisplayForAgent(2);
	updateDisplayForAgent(3);
	updateDisplayForAgent(4);
}

void updateDisplayForAgent(int index) {
	String selectString = '#agent'+index.toString();
	List<double> exps = [0,0];
	for(int arm=0; arm<2; arm++) {
		querySelector(selectString+'Alpha'+arm.toString()).text = nfAlphaBeta.format(agents[index].alphas[arm]);
		querySelector(selectString+'Beta'+arm.toString()).text = nfAlphaBeta.format(agents[index].betas[arm]);
		exps[arm] = agents[index].alphas[arm]/(agents[index].alphas[arm]+agents[index].betas[arm]);
		querySelector(selectString+'Exp'+arm.toString()).text = nfExp.format(exps[arm]);
	}
	if (exps[1] > exps[0] && machines[1].p > machines[0].p) {
		querySelector(selectString+'Correct').text = "Correctly believes Blue is best";
	}
	else if (exps[1] > exps[0] && machines[0].p > machines[1].p) {
		querySelector(selectString+'Correct').text = "Incorrectly believes Blue is best";
	}
	else if (exps[1] < exps[0] && machines[0].p > machines[1].p) {
		querySelector(selectString+'Correct').text = "Correctly believes Red is best";
	}
	else if (machines[0].p == machines[1].p) {
		querySelector(selectString+'Correct').text = "Both arms are equally good";
	}
	else {
		querySelector(selectString+'Correct').text = "Incorrectly believes Red is best";
	}

	SvgElement svgAgent = querySelector(selectString+'svg');
	plotBetaPDFs(svgAgent,agents[index]);
}

void plotBetaPDFs(SvgElement svgE, BetaAgent agent) {
	double stepSize = .01;
	double a = agents[0].alphas[0];
	double b = agents[0].betas[0];

	List<double> xVals = linSpace(0,stepSize,1/stepSize+1);
	List<double> yVals0;
	List<double> yVals1;

	//Need to check to see if the peak is too narrow/high for my simple integration
	//Method to successfully integrate over
	try {
		yVals0 = betaPDF(agent.alphas[0],agent.betas[0],xVals);
		yVals1 = betaPDF(agent.alphas[1],agent.betas[1],xVals);
	} 
	catch (e) {
		print(e);
		return;
	}

	List<double> pRangeY = getPlotRangeY(yVals0,yVals1);
	double scaleY = 1/pRangeY[1];

	paintPlot(svgE,xVals,yVals0,yVals1,[1,scaleY]);
}

void paintNetwork(bool isStar) {
	SvgElement svgE = querySelector('#network_svg');

	svgE.children.clear();

	String styleString = "fill:none;stroke:rgb(100,100,100);stroke-width:3";

	addNetworkLine(svgE,0,1,styleString);
	addNetworkLine(svgE,0,2,styleString);
	addNetworkLine(svgE,0,3,styleString);
	addNetworkLine(svgE,0,4,styleString);

	if (!isStar) {
		addNetworkArcsFrom1(svgE, styleString);
		addNetworkArcsFrom2(svgE, styleString);
		addNetworkArcsFrom3(svgE, styleString);
	}
}

void addNetworkArcsFrom1(SvgElement svgE, String s) {
	List<String> p = agentToNetworkCanvas(1);

	List<String> q = agentToNetworkCanvas(2);
	String d = "M "+p[0]+","+p[1] + "A 315 600 0 0 1 " + q[0]+","+q[1];
	PathElement path = new PathElement();
	path.setAttribute("d", d);
	path.setAttribute("style", s);
	svgE.children.add(path);

	q = agentToNetworkCanvas(3);
	d = "M "+p[0]+","+p[1] + "A 600 600 0 0 1 " + q[0]+","+q[1];
	path = new PathElement();
	path.setAttribute("d", d);
	path.setAttribute("style", s);
	svgE.children.add(path);

	q = agentToNetworkCanvas(4);
	d = "M "+p[0]+","+p[1] + "A 900 600 0 0 1 " + q[0]+","+q[1];
	path = new PathElement();
	path.setAttribute("d", d);
	path.setAttribute("style", s);
	svgE.children.add(path);
}

void addNetworkArcsFrom2(SvgElement svgE, String s) {
	List<String> p = agentToNetworkCanvas(2);

	List<String> q = agentToNetworkCanvas(3);
	String d = "M "+p[0]+","+p[1] + "A 315 400 0 0 1 " + q[0]+","+q[1];
	PathElement path = new PathElement();
	path.setAttribute("d", d);
	path.setAttribute("style", s);
	svgE.children.add(path);

	q = agentToNetworkCanvas(4);
	d = "M "+p[0]+","+p[1] + "A 600 200 0 0 1 " + q[0]+","+q[1];
	path = new PathElement();
	path.setAttribute("d", d);
	path.setAttribute("style", s);
	svgE.children.add(path);

}

void addNetworkArcsFrom3(SvgElement svgE, String s) {
	List<String> p = agentToNetworkCanvas(3);

	List<String> q = agentToNetworkCanvas(4);
	String d = "M "+p[0]+","+p[1] + "A 315 600 0 0 1 " + q[0]+","+q[1];
	PathElement path = new PathElement();
	path.setAttribute("d", d);
	path.setAttribute("style", s);
	svgE.children.add(path);
}

void addNetworkLine(SvgElement svgE, int i, int j, String styleString) {
	List<String> p = agentToNetworkCanvas(i);
	List<String> q = agentToNetworkCanvas(j);

	LineElement line = new LineElement();
	line.setAttribute("x1", p[0]);
	line.setAttribute("y1", p[1]);
	line.setAttribute("x2", q[0]);
	line.setAttribute("y2", q[1]);
	line.setAttribute("style",styleString);
	svgE.children.add(line);
}

List<String> agentToNetworkCanvas(int index) {
	if (index==0) 
		return ["770","0"];
	int outX = 143 + (index-1)*315;
	int outY = 100;
	return [outX.toString(), outY.toString()];
}

