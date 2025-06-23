allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

//android {
//    compileSdk = ... // Your compileSdkVersion
//    ndkVersion = "29.0.13599879" // <--- Add or change this line
//
//    defaultConfig {
//        // ...
//    }
//    // ... other configurations
//}

val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
