package cz.fit.cvut.wrzecond.agapesongs

import org.springframework.boot.autoconfigure.SpringBootApplication
import org.springframework.boot.autoconfigure.security.reactive.ReactiveSecurityAutoConfiguration
import org.springframework.boot.autoconfigure.security.servlet.SecurityAutoConfiguration
import org.springframework.boot.runApplication

@SpringBootApplication(exclude = [SecurityAutoConfiguration::class, ReactiveSecurityAutoConfiguration::class])
class AgapeSongsApplication

fun main(args: Array<String>) {
	runApplication<AgapeSongsApplication>(*args)
}
