import 'dart:math';

//Numerical integration by the trapezoidal rule.
//Used for caluclating demoninator of beta function PDF
double integrateTrapezoidal(var f, double a, double b) {
	return (b-a)*f((a+b)/2);
}

//Returns the numerator of the Beta distribution PDF
//This same function also appears inside the integral in the denominator
double betaFunctionFactory(double alpha, double beta) {
	return (v) => (pow(v,alpha-1)*pow(1-v,beta-1));
}

double betaDenominator(double alpha, double beta) {
	double du = .01;
	double sum = 0;
	var interiorFunction = betaFunctionFactory(alpha,beta);
	for(double u=0; u<1; u+=du) {
		sum += integrateTrapezoidal(interiorFunction,u,u+du);
	}
	return sum;
}

//Returns a list of x-values
List<double> xValues(double stepSize) {
	List<double> points = [];
	for (int i=0; i<=1; i+=stepSize) {
		points.add(i);
	}
	return points;
} 

//By-pass error in floating point arithmetic that prevented old method from reaching 1
List<double> linSpace(double start, double step, double numPoints) {
	List<double> points = [];
	double count = start;
	for (int i=0; i<numPoints; i++) {
		points.add(count);
		count += step;
	}
	//Hack it to avoid divergence at either 0 or 1 (e.g. alpha=beta=.5)
	double epsilon = step/100;
	points[0] = epsilon;
	points[points.length-1] = 1-epsilon; // Hack so that the final x is not slightly above 1
	return points;
}

//Returns a list of y-values
List<double> betaPDF(double alpha, double beta, List<double> xVals) {
	List<double> points = [];

	double denominator = betaDenominator(alpha,beta);
	var numerator = betaFunctionFactory(alpha,beta);

	//If the peak is too high and narrow it might be missed by the xVals given
	//This means all yVals will equal zero, and a variety of NaN/plotting errors occur
	if (denominator==0) {
		throw new Exception("Peak too narrow");
		return;
	}

	for (double x in xVals) {
		double y = numerator(x)/denominator;

		points.add(numerator(x)/denominator);
	}

	return points;
}

List<List<int>> makeCompleteGraph(int numAgents) {
	List adjMatrix = [];
	for(int i=0; i<numAgents; i++) {
		adjMatrix.add([]);
		for(int j=0; j<numAgents; j++) {
			adjMatrix[i].add(1);
		}
	}
	return adjMatrix;
}

List makeStarGraph(int numAgents) {
	List adjMatrix = [];
	for(int i=0; i<numAgents; i++) {
		adjMatrix.add([]);
		for(int j=0; j<numAgents; j++) {
			if(i==0 || i==j) {
				adjMatrix[i].add(1);
			}
			else {
				adjMatrix[i].add(0);
			}
		}
	}
	return adjMatrix;
}

class Network {
	List<BetaAgent> agents;
	List<Machine> machines;
	List adjMatrix;

	Network(List<BetaAgent> agents, List<Machine> machines, List<List<int>> adjMatrix) {
		this.agents = agents;
		this.machines = machines;
		this.adjMatrix = adjMatrix;
	}

	List<int> getActs() {
		List<int> acts = [];
		for (Agent agent in agents) {
			acts.add(agent.getMachineToPlay());
		}
		return acts;
	}

	List<int> getPayouts(List<int> acts) {
		List<int> payouts = [];
		for(int i=0; i<acts.length; i++) {
			payouts.add(machines[acts[i]].pull());
		}
		return payouts;
	}

	void step(List<int> acts, List<int> payouts) {
		//i is the index of the focal agent
		for(int i=0; i<adjMatrix.length; i++) {
			for(int j=0; j<adjMatrix[0].length; j++) {
				if (adjMatrix[i][j] == 1) {
					//The hub, whose index is zero, doesn't actually pull a lever
					if (j!=0) {
						agents[i].update(acts[j],payouts[j]);
					}
				}
			}
		}
	}
}

class BetaAgent {
	static final Random rGen = new Random();

	List<double> alphas;
	List<double> betas;

	BetaAgent() {
		alphas = [1,1];
		betas = [1,1];
		reset();
	}

	void reset() {
		for(int i=0; i<alphas.length; i++){
			alphas[i] = 4*rGen.nextDouble();
			betas[i] = 4*rGen.nextDouble();
		}
	}

	void resetFromInterval(List<double> alphaBounds, List<double> betaBounds) {
		for(int i=0; i<alphas.length; i++){
			alphas[i] = alphaBounds[0]+alphaBounds[1]*rGen.nextDouble();
			betas[i] = betaBounds[0]+betaBounds[1]*rGen.nextDouble();
		}
	}

	//Only valid for 0-1 payouts
	void update(int machineIndex, int payout) {
		alphas[machineIndex] += payout;
		betas[machineIndex] += 1 - payout;
	}

	//Only works with 2 machines
	int getMachineToPlay() {
		double exp0 = alphas[0] / (alphas[0] + betas[0] );
		double exp1 = alphas[1] / (alphas[1] + betas[1] );

		if (exp0 > exp1) {
			return 0;
		}
		return 1;
	}
}

class Machine {
	static final Random rGen = new Random();

	double p;

	Machine(double p) {
		this.p = p;
	}

	int pull() {
		double r = rGen.nextDouble();
		if (r<p) {
			return 0;
		}
		return 1;
	}
}

