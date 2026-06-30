<<<<<<< HEAD
plugins {
    id("com.google.gms.google-services") version "4.3.15" apply false
}

=======
>>>>>>> 36f1c013247f0425a92a148b9ef912be90b92e82
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
<<<<<<< HEAD

=======
>>>>>>> 36f1c013247f0425a92a148b9ef912be90b92e82
subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
