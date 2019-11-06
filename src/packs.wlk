class Pack {

	var vencimiento = new Date()

	method esInutil() = self.vencido() || self.acabado()

	method acabado()

	method vencido() = vencimiento < new Date()

	method puedeSatisfacer(consumo)

}

class PackConsumible inherits Pack {

	const property cantidad
	var cantidadConsumida = 0

	method consumir(consumo) {
		self.consumirCantidad(consumo.cantidad())
	}

	method consumirCantidad(_cantidad) {
		cantidadConsumida += _cantidad
	}

	method remanente() = cantidad - cantidadConsumida

	override method acabado() = self.remanente() <= 0

}

class Credito inherits PackConsumible {

	override method puedeSatisfacer(consumo) = consumo.costo() <= self.remanente()

}

class MBsLibres inherits PackConsumible {

	override method puedeSatisfacer(consumo) = consumo.cubiertoPorInternet(self)

	method puedeGastarMB(cantidad) = cantidad <= self.remanente()

}

class MBsLibresPlus inherits MBsLibres {

	override method puedeGastarMB(cantidad) = super(cantidad) || cantidad < 0.1

}

class PackIlimitado inherits Pack {

	method consumir(consumo) {
	}

	override method acabado() = false

	method puedeGastarMB(cantidad) = true

	method puedeGastarMinutos(cantidad) = true

}

class LlamadasGratis inherits PackIlimitado {

	method satisfaceConsumo(consumo) = consumo.cubiertoPorLlamadas(self)

}

class InternetLibreLosFindes inherits PackIlimitado {

	method satisfaceConsumo(consumo) = consumo.cubiertoPorInternet(self) && consumo.fechaRealizado().internalDayOfWeek() > 5

}

