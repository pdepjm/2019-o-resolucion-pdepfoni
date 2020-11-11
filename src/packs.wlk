class Pack {

	const vigencia = eterno
	const tipoGasto

	method esInutil() = vigencia.vencido() || self.acabado()

	method acabado() = tipoGasto.acabado()

	method puedeSatisfacer(consumo) = not vigencia.vencido() && self.cubre(consumo)

	method cubre(consumo)
	
	method consumir(consumo) { tipoGasto.consumir(consumo) }
	
	method remanente() = tipoGasto.remanente() // Testing
}

class Credito inherits Pack {

	override method cubre(consumo) = tipoGasto.cubreCantidad(consumo.costo())

}

class Internet inherits Pack {

	override method cubre(consumo) = consumo.cubiertoPorInternet(self)

	method puedeGastarMB(cantidad) = tipoGasto.cubreCantidad(cantidad)

}

class InternetLibreLosFindes inherits Internet{

	override method cubre(consumo) = super(consumo) && consumo.fechaRealizado().internalDayOfWeek() > 5

}

class InternetCantidadLibre inherits Internet {

	override method puedeGastarMB(cantidad) = super(cantidad) || cantidad < 0.1

}

class Llamadas inherits Pack {

	override method cubre(consumo) = consumo.cubiertoPorLlamadas(self)

	method puedeGastarMinutos(cantidad) = tipoGasto.cubreCantidad(cantidad)

}


// tipos de gasto
object ilimitado {

	method cubreCantidad(_cantidad) = true

	method acabado() = false
	
	method consumir(consumo) { }

	method remanente() { self.error("No hay remenete en un gasto ilimitado") }
}

class Consumible {

	const property cantidad
	const consumos = []

	method consumir(consumo) {
		consumos.add(consumo)
	}

	method cantidadConsumida() = consumos.sum({ consumo => consumo.cantidad() })

	method remanente() = cantidad - self.cantidadConsumida()

	method cubreCantidad(_cantidad) = _cantidad <= self.remanente()

	method acabado() = self.remanente() <= 0

}

//Vigencias
object eterno {

	method vencido() = false

}

class Vencimiento {

	const fecha

	method vencido() = fecha < new Date()

}

