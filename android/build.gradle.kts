import org.gradle.api.tasks.Delete
import org.gradle.api.file.Directory

buildscript {
    repositories {
        google()
        mavenCentral()
    }
    dependencies {
        classpath("com.android.tools.build:gradle:8.2.1") // Gradle plugin
        classpath("com.google.gms:google-services:4.3.15") // Firebase
    }
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// Cambiar buildDir global
val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.set(newBuildDir)

subprojects {
    project.layout.buildDirectory.set(newBuildDir.dir(project.name))
    project.evaluationDependsOn(":app")
}

// Tarea clean
tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
