const plotWidths = [140,120,90,80,65];
const insideRadii = [.4,.5,.6,.62,.64];
const outsideRadii = [.75,.8,.85,.86,.87];

var machines = [new BernoulliMachine(.6), new BernoulliMachine(.5)];

var numAgents = 9;

var agents = [];
for (var i=0; i<numAgents; i++) {
	agents[i] = new BetaAgent(2);
}

var adjMatrix = makeCompleteGraph(numAgents);

var net = new Network(agents,machines,adjMatrix);

var canvas = document.getElementById("myCanvas");
var ctx = canvas.getContext("2d");

//New coordinate system located at the center of the canvas
var halfHeight = canvas.height/2;
var halfWidth = canvas.width/2;

var radiusInside = insideRadii[0]*halfHeight;
var radiusOutside = outsideRadii[0]*halfHeight;
var plotWidth = plotWidths[0];

// ctx.translate(radius,radius);
ctx.transform(1,0,0,1,halfWidth,halfHeight);

updateDisplay(ctx, net, radiusInside, radiusOutside, plotWidths[0]);


function stepForward() {
	net.step();

	updateDisplay(ctx,net,radiusInside, radiusOutside, plotWidth);
}

function reset() {
	//Arm data
	numArms = document.getElementById('num_arms_input').value;
	armRateElements = document.getElementsByName('arm_rate');
	machines = [];
	for (var i=0; i<numArms; i++) {
		machines[i] = new BernoulliMachine(armRateElements[i].value);
	}

	//Alphas and Betas
	var alpha0 = parseFloat(document.getElementById('alpha_lower_text').value);
	var alpha1 = parseFloat(document.getElementById('alpha_upper_text').value);
	var beta0 = parseFloat(document.getElementById('beta_lower_text').value);
	var beta1 = parseFloat(document.getElementById('beta_upper_text').value);
	

	//Agents
	numAgents = document.getElementById('num_agents_input').value;
	agents = [];
	for (var i=0; i<numAgents; i++) {
		agents[i] = new BetaAgent(numArms);
		agents[i].resetWith([alpha0,alpha1],[beta0,beta1]);
	}

	//Network
	var net_radio = document.getElementsByName('net_radio');
	var adjMatrix = [];
	if (net_radio[0].checked)
		adjMatrix = makeCompleteGraph(numAgents);
	else if (net_radio[1].checked)
		adjMatrix = makeCycleGraph(numAgents);
	else if (net_radio[2].checked)
		adjMatrix = makeWheelGraph(numAgents);
	else if (net_radio[3].checked)
		adjMatrix = makeLineGraph(numAgents);
	else if (net_radio[4].checked)
		adjMatrix = makeStarGraph(numAgents);
	else
		adjMatrix = makeTwoCliquesGraph(numAgents);

	net = new Network(agents,machines,adjMatrix);

	//Massage display parameters
	index = 0;
	if (numAgents>9 && numAgents<=11)
		index = 1;
	else if (numAgents>11 && numAgents<=14) 
		index = 2;
	else if (numAgents>14 && numAgents<=16)
		index = 3;
	else if (numAgents>16)
		index = 4;

	plotWidth = plotWidths[index];
	radiusInside = insideRadii[index]*halfHeight;
	radiusOutside = outsideRadii[index]*halfHeight;

	updateDisplay(ctx,net,radiusInside, radiusOutside, plotWidth);
}

function armSlide(v) {
	document.getElementById('num_arms_span').innerHTML = v;

	armRateElements = document.getElementsByName('arm_rate');

	for(var i=0; i<armRateElements.length; i++) {
		if(i<v)
			armRateElements[i].removeAttribute("disabled");
		else
			armRateElements[i].setAttribute("disabled","true");
	}

	reset();
}

function agentsSlide(v) {
	document.getElementById('num_agents_span').innerHTML = v;

	reset();
}

