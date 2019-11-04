object pdepfoni {

	method costoMB() = 0.1

	method costoMinuto() = 4

}

class Linea {

	var plan
	var packs
	var consumos = []
	var tipoLinea = comun
	var deuda = 0

	method costoConsumo(consumo) = consumo.costo()

	method agregarPack(nuevoPack) {
		packs.add(nuevoPack)
	}

	method planYPacks() = plan + packs

	method sePuedeRealizarConsumo(consumo) = self.planYPacks().anyOne({ conjuntoOfertas => conjuntoOfertas.cubreConsumo(consumo) })

	method realizarConsumo(consumo) {
		var cubridorDeConsumo = self.planYPacks().reverse().findOrElse({ conjuntoOfertas => conjuntoOfertas.cubreConsumo() }, { tipoLinea.accionConsumoNoRealizable(self) })
		cubridorDeConsumo.restarConsumo(consumo)
		consumos.add(new ConsumoRealizado(consumo = consumo, fechaConsumo = new Date()))
	}

	method limpiezaPacks() { // deprecado xd
		packs.removeAllSuckThat({ pack => pack.esInutil()})
	}

	method gastosEnElMes() = consumos.filter({ consumo => consumo.consumidoEnElMes() }).map({ consumo => consumo.cantidadMB() })

	method promedioConsumos() = consumos.sum({ consumo => consumo.costo() }) / consumos.size()

	method cambioTipoLinea(nuevoTipo) {
		tipoLinea = nuevoTipo
	}

	method sumarDeuda(cantidadDeuda) {
		deuda += cantidadDeuda
	}

}

object platinum {

	method accionConsumoNoRealizable(linea, costoConsumo) {
		linea.sumarDeuda(costoConsumo)
	}

}

object black {

	method accionConsumoNoRealizable(linea, costoConsumo) {
	}

}

object comun {

	method accionConsumoNoRealizable(linea, costoConsumo) {
		self.error("Ninguna oferta cubre el consumo y no se me ocurre ninguna manera graciosa de informarlo.")
	}

}

class ConsumoRealizado {

	var consumo
	var fechaConsumo

	method consumidoEnElMes() = new Date() - fechaConsumo < 30

	method cantidadMB() = consumo.cantidadMB()

	method costo() = consumo.costo()

}

//planes y packs
class Plan {

	var ofertas

	method cubreConsumo(consumo) = ofertas.anyOne({ oferta => oferta.satisfaceConsumo(consumo) })

}

class Pack inherits Plan {

	var vencimiento = new Date()

	method esInutil() = self.vencido() || ofertas.all({ oferta => oferta.acabado() })

	method vencido() = vencimiento < new Date()

	override method cubreConsumo(consumo) = super(consumo) && self.vencido()

}

//Ofertas
class OfertaFinita {

	var cantidad
	var tipoOfertaFinita = normal

	method resta(consumo)

	method restarConsumo(consumo) {
		cantidad -= tipoOfertaFinita.cuantoResta(self.resta(consumo))
	}

	method acabado() = cantidad <= 0

}

class Credito inherits OfertaFinita {

	override method resta(consumo) = consumo.costo()

	method satisfaceConsumo(consumo) = consumo.cubirtoPorOfertaCredito(cantidad)

}

class MBsLibres inherits OfertaFinita {

	override method resta(consumo) = consumo.cantidadMB()

	method satisfaceConsumo(consumo) = consumo.cubiertoPorOfertaMB(cantidad)

}

class Descuento {

	var porcentaje

	method cuantoResta(cantidadOriginal) = cantidadOriginal - cantidadOriginal * porcentaje

}

object suerte {

	method cuantoResta(cantidadOriginal) = if (0.randomUpTo(1) > 0.2) cantidadOriginal else 0

}

object normal {

	method cuantoResta(cantidadOriginal) = cantidadOriginal

}

class OfertaInfinita {

	method restarConsumo(consumo) {
	}

	method acabado() = false

}

object internetLibreLosFindes inherits OfertaInfinita {

	method satisfaceConsumo(consumo) = consumo.cubiertoPorInternetEnElFinde()

}

object llamadasGratis inherits OfertaInfinita {

	method satisfaceConsumo(consumo) = consumo.cubiertoPorLlamadasGratis()

}

//Consumos
class Consumo {

	method costo()

	method cubirtoPorOfertaCredito(cantidadCredito) = cantidadCredito > self.costo()

}

class MBsDeInternet inherits Consumo {

	var cantidadMB

	method cantidadMB() = cantidadMB

	override method costo() = cantidadMB * pdepfoni.costoMB()

	method cubiertoPorOfertaMB(cantidadMBOferta) = cantidadMB < cantidadMBOferta

	method cubiertoPorInternetEnElFinde() = new Date().internalDayOfWeek() > 5

	method cubiertoPorLlamadasGratis() = false

}

class MinutosDeLinea inherits Consumo {

	var cantidadMinutos

	method cantidadMB() = 0

	method cantidadMinutos() = cantidadMinutos

	method cubiertoPorOfertaMB(cantidadMBOferta) = false

	method cubiertoPorInternetEnElFinde() = false

	override method costo() = cantidadMinutos * pdepfoni.costoMinuto()

	method cubiertoPorLlamadasGratis() = true

}

