//////////////////////////////////ARMAS/////////////////////////////////

class Arma{
	const calibre
	const potenciaDestructiva
	
	method poderOfencivo(){
		return 2 * calibre + potenciaDestructiva
	}
	
	//ruidosas o silenciosas?
	
}

/////////////////////////////SOBREVIVIENTES////////////////////////////////////

class Sobreviviente{
	var property resistencia = 40
	var property carisma = 1
	var property estado	//ver tema tipos
	const property armas = new List() //poner corchetes //VER SI ES UTIL EL PROPERTY
	var poderBase = 1
	
	method puedeAtacar(){
		return resistencia > 12
	}
	
	method atacar(caminante){
		if(self.puedeAtacar()){
			resistencia -= 2
			estado.efectoAtacar(self)
		}else{
			//ataqueException = // implementar
		}
	}
	
	method poder(){
		return poderBase * (1 + carisma/100)
	}
	
	method poderOfensivo(){
		return armas.anyOne().poderOfensivo() + self.poder()
	}
}

////////////////////////////////////ESTADOS//////////////////////////////////

object saludable{
	
	method efectoAtacar(sobreviviente){
		//no hace nada
	}
	
	method efectoComer(sobreviviente){
		//no hace nada
	}
	
}

object arrebatado{
	
	method efectoAtacar(sobreviviente){
		sobreviviente.carisma(sobreviviente.carisma()-2)
	}
	
	method efectoComer(sobreviviente){
		sobreviviente.resistencia(sobreviviente.resistencia() + 50)
		sobreviviente.carisma(sobreviviente.carisma() + 20)
	}
}

class Infectado{
	
	var ataquesRealizados = 0 
	
	method efectoAtacar(sobreviviente){
		sobreviviente.resistencia(sobreviviente.resistencia() - 3)
		ataquesRealizados += 1
		
		if(ataquesRealizados > 5){
			sobreviviente.desmayarDelDolor()
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
	
	method efectoAtacar(sobreviviente){
		//no hace nada
	}
	
	method efectoComer(sobreviviente){
		sobreviviente.estado(saludable) 
	}
}

/////////////////////////////////PREDADOR//////////////////////////////////

class Predador inherits Sobreviviente{
	const caminantesEsclavizados = #{}
	
	method intentarEsclavizarCaminate(caminante){
		if(caminante.estaDevil()){
			caminantesEsclavizados.add(caminante)
		}
	}
	
	override method atacar(caminante){
		super(caminante)
		self.intentarEsclavizarCaminate(caminante)
	}
	
	override method poderOfensivo(){
		var poderOfensivoBase = super() / 2
		poderOfensivoBase += caminantesEsclavizados.map({caminante => caminante.poderCorrosivo()}).sum()
		return poderOfensivoBase
	}
}

///////////////////////////////////CAMINANTES///////////////////////////////////

class Caminante{
	var sedDeSangre = 45
	var estaSomnoliento = true
	var cantidadDientes = 2
	
	method poderCorrosivo() = 2 * sedDeSangre + cantidadDientes
	
	method estaDebil(){
		return (sedDeSangre < 15) && estaSomnoliento
	}
	
}

////////////////////////////////GRUPOS////////////////////////////////

class Grupo{
	const integrantes = #{}
	
	method lider(){
		return integrantes.max({sobreviviente => sobreviviente.carisma()}) 
		//devuelve el <integrante> con mayor carisma. No devuelve el mayor carisma
	}
	
	method poderOfensivo(){
		return self.lider().carisma() * integrantes.map({sobreviviente => sobreviviente.poderOfensivo()}).sum()
	}
	
	method puedeTomarLugar(unLugar){
		return self.poderOfensivo() > unLugar.poderCorrosivo()
	}
	
	method tomarLugar(unLugar){
		if(self.puedeTomarLugar(unLugar) && unLugar.complejidadExtra()){ //hay una mejor solucion en foto
		// pa que este metodo esté en el LUGAR en ves de en el GRUPO
			//implementar
		}else{
			//tomaDeLugarExcepcion //IMPLEMENTAR	
		}
	}
}

////////////////////////////////LUGARES/////////////////////////////////////

class Lugar{
	const caminantes = #{}
	
	method poderCorrosivo(){
		return caminantes.map({caminante => caminante.poderCorrosivo()}).sum()
	}
}

class Prision inherits Lugar{
	const cantidadPabellones
	
	method complejidadExtra(){
		
	}
	
	method beneficios(){
		
	}
}

class Granja inherits Lugar{
	method complejidadExtra(){
		
	}
	
	method beneficios(){
		
	}
}

class Bosque inherits Lugar{
	method complejidadExtra(){
		
	}
	
	method beneficios(){
		
	}
}
