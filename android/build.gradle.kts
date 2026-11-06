allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
// Some plugins (geolocator_android, pedometer) still compile with Java 8, which
// JDK 21 reports as obsolete. Pin every Android library to Java/Kotlin 17
// (the highest target any current plugin uses). This runs in afterEvaluate,
// after the plugin's own build file but before AGP finalizes its DSL.
subprojects {
    val pinJvmTarget17 = {
        extensions.findByType<com.android.build.api.dsl.LibraryExtension>()?.compileOptions?.apply {
            sourceCompatibility = JavaVersion.VERSION_17
            targetCompatibility = JavaVersion.VERSION_17
        }
        tasks.withType<org.jetbrains.kotlin.gradle.tasks.KotlinJvmCompile>().configureEach {
            compilerOptions.jvmTarget.set(org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17)
        }
    }
    if (state.executed) pinJvmTarget17() else afterEvaluate { pinJvmTarget17() }
}
subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
