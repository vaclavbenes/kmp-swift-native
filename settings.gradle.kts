dependencyResolutionManagement {
    repositories {
        maven("https://packages.jetbrains.team/maven/p/kt/dev")
        mavenCentral()
    }
}
pluginManagement {
    repositories {
        maven("https://packages.jetbrains.team/maven/p/kt/dev")
        mavenCentral()
        gradlePluginPortal()
    }
}

rootProject.name = "kmp-swift-native"
