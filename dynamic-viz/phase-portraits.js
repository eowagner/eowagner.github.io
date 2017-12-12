const colors = ["#800080", "#008000"]; //Purple and Green -- complementary colors


const x_buff = 40;
const y_buff = 40;

var canvas;
var ctx;
var can_height;
var can_width;

// Converts 3-D points to 2-D points on a simplex
function freqToSimplex(x) {
	return [x[1] + .5*x[2], Math.sqrt(3)/2 *x[2]];
}

// Converts simplex coordinates to points on the canvas
function simplexToCanvas(x) {
	// return [x[0]*(can_width-(x_buff*2))+x_buff, can_height-(x[1]*(can_height-y_buff*2)+y_buff)];
	return [x[0]*(can_width-(x_buff*2))+x_buff, can_height-(x[1]*(can_width-y_buff*2)+y_buff)]; // Assumes that the canvas is shapped for an equilateral traiangle
}

function freqToLoc(x) {
	return simplexToCanvas(freqToSimplex(x));
}

function locToSimplex(p) {
	return [(p.x-x_buff)/(can_width-(x_buff*2)), -1*(p.y+y_buff-can_height)/(can_width-y_buff*2)];
}

function simplexToFreq(x) {
	var z2 = x[1] * 2 / Math.sqrt(3);
	var z1 = x[0] - .5*z2;
	var z0 = 1 - z1 - z2;
	return [z0, z1, z2];
}

function locToFreq(p) {
	return simplexToFreq(locToSimplex(p));
}

function drawSimplex() {
	var a = freqToLoc([1,0,0]);
	var b = freqToLoc([0,1,0]);
	var c = freqToLoc([0,0,1]);

	ctx.strokeStyle = "#000000";
	ctx.fillStyle = "#000000";

	ctx.beginPath();
	ctx.lineWidth = 5;
	ctx.moveTo(a[0], a[1]);
	ctx.lineTo(b[0], b[1]);
	ctx.lineTo(c[0], c[1]);
	ctx.lineTo(a[0], a[1]);
	ctx.stroke();

	ctx.font = '30px serif';
  	ctx.fillText('x'+String.fromCharCode(8320), 10, can_height-15);
  	ctx.fillText('x'+String.fromCharCode(8321), can_width-30, can_height-15);
  	ctx.fillText('x'+String.fromCharCode(8322), can_width/2-10, 20);
}

function drawOrbit(x0) {
	// var dynList = [replicator, brownVonNeumannNash, smithDynamic, smoothedBestResponse];
	var dynList = [replicator, brownVonNeumannNash, smithDynamic];
	var colors = ["#029386", "#f97306", "#650021", "#6e750e"]

	var s = freqToLoc(x0);
	ctx.beginPath();
	ctx.arc(s[0], s[1], 5, 0, 2*Math.PI);
	ctx.fill();

	for (var j=0; j<dynList.length; j++) {
		var points = solutionOrbit(A, x0, dynList[j]);

		var x = freqToLoc(points[0]);

		ctx.beginPath();
		ctx.strokeStyle = colors[j];
		ctx.lineWidth = 2;
		ctx.moveTo(x[0], x[1]);
		for (var i=1; i<points.length; i++) {
			x = freqToLoc(points[i]);
			ctx.lineTo(x[0], x[1]);
		}

		ctx.stroke();
	}
}

function clickedAt(loc) {
	var freq = locToFreq(loc);
	
	if (freq[0]<0 || freq[0]>1 || freq[1]<0 || freq[1]>1 || freq[2]<0 || freq[2]>1)
		return;

	drawOrbit(locToFreq(loc));
}

function reset() {
	ctx.fillStyle = "#F5F5F5";
	ctx.fillRect(0,0,can_width,can_height);

	drawSimplex();
}

function payoff_reset() {
	var m = [ [0,0,0], [0,0,0], [0,0,0] ];

	m[0][0] = document.getElementById("t00").value;
	m[0][1] = document.getElementById("t01").value;
	m[0][2] = document.getElementById("t02").value;

	m[1][0] = document.getElementById("t10").value;
	m[1][1] = document.getElementById("t11").value;
	m[1][2] = document.getElementById("t12").value;

	m[2][0] = document.getElementById("t20").value;
	m[2][1] = document.getElementById("t21").value;
	m[2][2] = document.getElementById("t22").value;

	A = m;
}

function payoff_reset_zeeman() {
	A = zeeman;

	document.getElementById("t00").value = A[0][0];
	document.getElementById("t01").value = A[0][1];
	document.getElementById("t02").value = A[0][2];

	document.getElementById("t10").value = A[1][0];
	document.getElementById("t11").value = A[1][1];
	document.getElementById("t12").value = A[1][2];

	document.getElementById("t20").value = A[2][0];
	document.getElementById("t21").value = A[2][1];
	document.getElementById("t22").value = A[2][2];
}

$( document ).ready(function() {    
    canvas = document.getElementById("myCanvas");
    ctx = canvas.getContext("2d");
    can_height = canvas.height;
	can_width = canvas.width;

	drawSimplex();

	document.getElementById("myCanvas").addEventListener("click", function( event ) {
    	clickedAt({ x: event.offsetX, y: event.offsetY });
  	}, false);
});