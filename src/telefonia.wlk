class Linea {

	const packs = []
	const consumos = []
	var property tipoLinea = comun
	var property deuda = 0

	method gastoMBUltimoMes() = self.gastosEntre(new Date().minusDays(3), new Date()).sum({ consumo => consumo.cantidadMB() })

	method gastosEntre(min, max) = consumos.filter({ consumo => consumo.consumidoEntre(min, max) })

	method promedioConsumos() = consumos.sum({ consumo => consumo.costo() }) / consumos.size()

	method agregarPack(nuevoPack) {
		packs.add(nuevoPack)
	}

	method puedeRealizarConsumo(consumo) = packs.any({ pack => pack.puedeSatisfacer(consumo) })

	method realizarConsumo(consumo) {
		if (not self.puedeRealizarConsumo(consumo)) tipoLinea.accionConsumoNoRealizable(self, consumo) else self.consumirPack(consumo)
	}

	method consumirPack(consumo) {
		var pack = packs.reverse().find({ pack => pack.puedeSatisfacer(consumo) })
		pack.consumir(consumo)
		consumos.add(consumo)
	}

	method limpiezaPacks() {
		packs.removeAllSuchThat({ pack => pack.esInutil()})
	}

	method sumarDeuda(cantidadDeuda) {
		deuda += cantidadDeuda
	}

}

object platinum {

	method accionConsumoNoRealizable(linea, consumo) {
	}

}

object black {

	method accionConsumoNoRealizable(linea, consumo) {
		linea.sumarDeuda(consumo.costo())
	}

}

object comun {

	method accionConsumoNoRealizable(linea, consumo) {
		self.error("Los packs de la línea no pueden cubrir el consumo.")
	}

}

