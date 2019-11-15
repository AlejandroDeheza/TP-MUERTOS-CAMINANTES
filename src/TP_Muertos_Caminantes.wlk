//////////////////////////////////ARMAS/////////////////////////////////

class Arma{
	const calibre = 10 //valor arbitrario
	const potenciaDestructiva = 20 //valor arbitrario
	const property esRuidosa = true
	
	method poderOfencivoArma(){
		return 2 * calibre + potenciaDestructiva
	}
	
}

/////////////////////////////SOBREVIVIENTES////////////////////////////////////
class AtaqueException inherits Exception { }

class Sobreviviente{
	var property resistencia = 50 //valor arbitrario
	var property carisma = 50 //valor arbitrario
	var property estado
	const property armas = []
	const poderBase = 50 //valor arbitrario
	
	method puedeAtacar(){
		return resistencia > 12
	}
	
	method atacar(caminante){
		if(self.puedeAtacar()){
			resistencia -= 2
			estado.efectoAdicionalAlAtacar(self)
		}else{
			throw new AtaqueException( 
				message = "No es posible atacar, resistencia insuficiente"
			)
		}
	}
	
	method poder(){
		return poderBase * (1 + carisma/100)
	}
	
	method poderOfensivo(){
		return armas.anyOne().poderOfencivoArma() + self.poder()
	}
	
	method consumirGuarnicionCuradora(){
		estado.efectoComer(self)
	}
}

////////////////////////////////ESTADOS de los sobrevivientes/////////////////////////

object saludable{
	
	method efectoAdicionalAlAtacar(sobreviviente){
		//no hace nada
	}
	
	method efectoComer(sobreviviente){
		//no hace nada
	}
	
}

object arrebatado{
	
	method efectoAdicionalAlAtacar(sobreviviente){
		sobreviviente.carisma(sobreviviente.carisma() + 1)
	}
	
	method efectoComer(sobreviviente){
		sobreviviente.resistencia(sobreviviente.resistencia() + 50)
		sobreviviente.carisma(sobreviviente.carisma() + 20)
	}
}

class Infectado{
	
	var ataquesRealizados = 0 
	
	method efectoAdicionalAlAtacar(sobreviviente){
		sobreviviente.resistencia(sobreviviente.resistencia() - 3)
		ataquesRealizados += 1
		
		if(ataquesRealizados > 5){
			sobreviviente.estado(desmayado)
		}
	}
	
	method efectoComer(sobreviviente){
		sobreviviente.resistencia(sobreviviente.resistencia() + 40)
		
		if(ataquesRealizados > 3){
			ataquesRealizados = 0
		}else{
			sobreviviente.estado(saludable) 
		}
	}
}

object desmayado{
	
	method efectoAdicionalAlAtacar(sobreviviente){
		//no hace nada
	}
	
	method efectoComer(sobreviviente){
		sobreviviente.estado(saludable) 
	}
}

/////////////////////////////////PREDADOR//////////////////////////////////

class Predador inherits Sobreviviente{
	const caminantesEsclavizados = #{}
	
	method intentarEsclavizar(caminante){
		if(caminante.estaDebil()){
			caminantesEsclavizados.add(caminante)
		}
	}
	
	override method atacar(caminante){
		super(caminante)
		self.intentarEsclavizar(caminante)
	}
	
	override method poderOfensivo(){
		var poderOfensivoPredador = super() / 2
		poderOfensivoPredador += caminantesEsclavizados.map(
			{caminante => caminante.poderCorrosivo()}
		).sum()
		return poderOfensivoPredador
	}
}

///////////////////////////////////CAMINANTES///////////////////////////////////

class Caminante{
	var sedDeSangre = 30 //valor arbitrario
	var estaSomnoliento = true	//valor arbitrario
	var cantidadDientes = 12 //valor arbitrario
	
	method poderCorrosivo() = 2 * sedDeSangre + cantidadDientes
	
	method estaDebil(){
		return (sedDeSangre < 15) && estaSomnoliento
	}
	
}

////////////////////////////////GRUPOS////////////////////////////////

class Grupo{
	const property integrantes = #{}
	var property posicionActual
	
	method lider(){
		return integrantes.max({sobreviviente => sobreviviente.carisma()}) 
		//devuelve el <integrante> con mayor carisma. No devuelve el mayor carisma
	}
	
	method poderOfensivo(){
		return self.lider().carisma() * integrantes.map(
			{sobreviviente => sobreviviente.poderOfensivo()}
		).sum()
	}
	
	method puedeTomar(unLugar){
		return self.poderOfensivo() > unLugar.poderCorrosivoTotal()
	}
	
	method atacantes(){
		return integrantes.filter{integrante => integrante.puedeAtacar()}
	}
	
	method integrantesJodidos(){
		return integrantes.filter({integrante => integrante.resistencia() < 40})
	}
	
	method miembroMasDevil(){
		return integrantes.min({sobreviviente => sobreviviente.poderOfensivo()})
	}
}

////////////////////////////////LUGARES/////////////////////////////////////

class Lugar{
	const caminantes = #{}
	
	method puedeSerTomadoEspecifico(unGrupo)
	
	method beneficioAlTomarLugar(unGrupo)
	
	method tomarLugarPor(unGrupo){
		if(unGrupo.puedeTomar(self) && self.puedeSerTomadoEspecifico(unGrupo)){ 
			unGrupo.posicionActual(self)
			caminantes.forEach(
				{caminante => unGrupo.integrantes().anyOne().atacar(caminante)}
			)
			self.beneficioAlTomarLugar(unGrupo)
		}else{
			unGrupo.integrantes().remove(unGrupo.miembroMasDevil())
			var infeccion = new Infectado()
			unGrupo.integrantesJodidos().forEach(
				{integrante => integrante.estado(infeccion)}
			)
		}
	}
	
	method caminantes(){
		return caminantes// hago el getter porque me marca un warning si uso el property
		//por la herencia
	}
	
	method poderCorrosivoTotal(){
		return caminantes.map({caminante => caminante.poderCorrosivo()}).sum()
	}
}

class Prision inherits Lugar{
	const cantidadPabellones = 20 //valor arbitrario
	const armasPrision = #{}
	
	override method puedeSerTomadoEspecifico(unGrupo){
		return unGrupo.poderOfensivo() > (cantidadPabellones * 2)
	}
	
	override method beneficioAlTomarLugar(unGrupo){
		unGrupo.miembroMasDevil().armas().addAll(armasPrision)
	}
}

class Granja inherits Lugar{
	override method puedeSerTomadoEspecifico(unGrupo){
		return true // no tienen exigencias extras
	}
	
	override method beneficioAlTomarLugar(unGrupo){
		unGrupo.integrantes().forEach{
			integrante => integrante.consumirGuarnicionCuradora()
		}
	}
}

class Bosque inherits Lugar{
	var tieneNiebla = true
	
	override method puedeSerTomadoEspecifico(unGrupo){
		return unGrupo.atacantes().all{
			atacante => atacante.armas().all({arma => arma.esRuidosa().negate()})
		}
	}
	
	override method beneficioAlTomarLugar(unGrupo){
		if(tieneNiebla){
			var integranteDesafortunado = unGrupo.integrantes().anyOne()
			integranteDesafortunado.armas().remove(integranteDesafortunado.armas().anyOne())
		}
	}
}
