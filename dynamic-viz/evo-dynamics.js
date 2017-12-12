function erfInverse(x) {
	var a = .140012;

	var t1 = 2/(Math.PI*a) + Math.log(1-x*x)/2;
	var t2 = Math.log(1-x*x)/a;

	return Math.sign(x) * Math.sqrt( Math.sqrt(t1*t1 - t2) - t1 );
}

function normalQuantileFunction(mean, variance, p) {
	return mean + Math.sqrt(variance *2) * this.erfInverse(2*p-1);
}

function randomNormal(mean, variance) {
	var r = Math.random();

	return normalQuantileFunction(mean, variance, r);
}

// returns the rate of change for all dimenssions of the replicator dynamic
function replicator(A, x) {
	var expPayoffs = matMult(A,x);
	var avg = innerProd(x, expPayoffs); 
	
	var xDot = [0,0,0];
	for (var i=0; i<xDot.length; i++) {
		xDot[i] = x[i] * (expPayoffs[i] - avg);
	}

	return xDot;
}

function matMult(A, x) {
	var y = [0,0,0];
	for (var r=0; r< A.length; r++) {
		y[r] = 0;
		for (var c=0; c<A[0].length; c++) {
			y[r] += A[r][c]*x[c];
		}
	}
	return y;
}

function innerProd(a, b) {
	var c = 0;
	for (var i=0; i<a.length; i++) {
		c += a[i]*b[i];
	}
	return c;
}

function brownVonNeumannNash(A, x) {
	var expPayoffs = matMult(A,x);
	var avg = innerProd(x, expPayoffs);

	var posPart = x => (x>0) ? x : 0;

	var xDot = [0, 0, 0];

	for (var i=0; i<xDot.length; i++) {
		xDot[i] += posPart(expPayoffs[i] - avg);

		for (var j=0; j<xDot.length; j++) {
			xDot[i] -= x[i] * posPart(expPayoffs[j] - avg);
		}
	}

	return xDot;
}

function smithDynamic(A, x) {
	var exp = matMult(A, x);
	var posPart = x => (x>0) ? x : 0;

	var xDot = [0, 0, 0];

	for (var i=0; i<xDot.length; i++) {
		for (var j=0; j<xDot.length; j++) {
			xDot[i] += x[j] * posPart(exp[i] - exp[j]);
		}

		for (var j=0; j<xDot.length; j++) {
			xDot[i] -= x[i] * posPart(exp[j] - exp[i]);
		}
	}

	return xDot;
}

function smoothedBestResponse(A, x) {
	var gamma = .01;

	var expPayoffs = matMult(A, x);

	var exp = expPayoffs.map(a => Math.exp(a/gamma));

	var sum = exp.reduce( (a,b) => a+b);

	var xDot = [0,0,0];

	for (var i=0; i<xDot.length; i++) {
		xDot[i] = (exp[i] / sum) - x[i];
	}

	return xDot;
}

function eulerMethod(f, x, h) {
	var xPrime = Array(x.length);
	for (var i=0; i<xPrime.length; i++) {
		xPrime[i] = x[i] + h*f[i];
	}
	return xPrime;
}

function solutionOrbit(A, x0, dynamic) {
	var points = [x0];
	var x = x0;
	var h = .01;

	for (var i=0; i<10000; i++) {
		var f = dynamic(A, x);
		var xPrime = eulerMethod(f, x, h);
		points.push(xPrime);
		x = xPrime;
	}

	return points;
}


var zeeman =  [[0,6,-4], [-3,0,5], [-1,3,0]];
var A = zeeman;