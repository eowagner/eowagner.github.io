const bufferX = 0;
const bufferY = 0;

function paintFunctionAt(xValues, yValues, ctx, centerPoint, width, height, pRange, styleString) {
	var origin = getOrigin(centerPoint, width, height);

	var transform = xyTransformFactory(origin,width,height,pRange);

	ctx.beginPath();
	ctx.strokeStyle = styleString;

	var p = transform({x: xValues[0], y: yValues[0]});
	ctx.moveTo(p.x,p.y);

	for (var i=1; i<xValues.length; i++) {
		p = transform({x: xValues[i], y: yValues[i]});
		ctx.lineTo(p.x,p.y);
	}

	ctx.stroke();
}

function paintAxesAt(ctx, centerPoint, width, height, pRange) {
	var origin = getOrigin(centerPoint, width, height, pRange);

	var yEnd = xyFromPlotPoint({x:pRange[0][0],y:pRange[1][1]}, origin, width, height, pRange);
	var xEnd = xyFromPlotPoint({x:pRange[0][1],y:pRange[1][0]}, origin, width, height, pRange);

	var transform = xyTransformFactory(origin,width,height,pRange);

	ctx.beginPath();
	ctx.strokeStyle = 'rgb(0,0,0)';
	ctx.moveTo(yEnd.x, yEnd.y);
	ctx.lineTo(origin.x, origin.y);
	ctx.lineTo(xEnd.x, xEnd.y);
	ctx.stroke();

	ctx.fillStyle = "rgb(0,0,0)";
	ctx.textAlign = "center";
	ctx.font = "14px Verdana";
	ctx.fillText("PDF",centerPoint.x,centerPoint.y-height/2-4);

	ctx.font = "13px Verdana";
	ctx.fillText("0.0", origin.x, origin.y+16);
	ctx.fillText("0.5", transform({x:.5,y:0}).x, origin.y+16);
	ctx.fillText("1.0", transform({x:1,y:0}).x, origin.y+16);

	ctx.fillText("0.0", origin.x-12, origin.y+5);
	ctx.fillText((.5*pRange[1][1]).toPrecision(2), origin.x-12, transform({x:0,y:.5*pRange[1][1]}).y+5);
	ctx.fillText(pRange[1][1].toPrecision(2), origin.x-12, transform({x:0,y:pRange[1][1]}).y+5);

	// Draw the light grey guidelines
	// ctx.beginPath();
	// ctx.strokeStyle = 'rgb(200,200,200)';

	// var p = transform( {x:0, y: .5*pRange[1][1]} );
	// ctx.moveTo(p.x,p.y);
	// p = transform( {x:1, y: .5*pRange[1][1]} );
	// ctx.lineTo(p.x,p.y);

	// p = transform( {x:0, y: pRange[1][1]} );
	// ctx.moveTo(p.x,p.y);
	// p = transform( {x:1, y: pRange[1][1]} );
	// ctx.lineTo(p.x,p.y);

	// p = transform( {x:.5, y: 0} );
	// ctx.moveTo(p.x,p.y);
	// p = transform( {x:.5, y: pRange[1][1]} );
	// ctx.lineTo(p.x,p.y);

	// p = transform( {x: 1, y: 0} );
	// ctx.moveTo(p.x,p.y);
	// p = transform( {x: 1, y: pRange[1][1]} );
	// ctx.lineTo(p.x,p.y);

	// ctx.stroke();
}


function getOrigin(centerPoint, width, height) {
	return { x: centerPoint.x-width/2+bufferX, y: centerPoint.y+height/2-bufferY};
}

function xyFromPlotPoint(point, origin, width, height, pRange) {
	var xScale = 1.0/(pRange[0][1] - pRange[0][0]);
	var yScale = 1.0/(pRange[1][1] - pRange[1][0]);

	return { x: origin.x + point.x*xScale*(width-bufferX)-pRange[0][0],
			y: origin.y - point.y*yScale*(height-bufferY)+pRange[1][0] };
}

function xyTransformFactory(origin, width, height, pRange) {
	return function(point) {
		return xyFromPlotPoint(point, origin, width, height, pRange);
	}
}