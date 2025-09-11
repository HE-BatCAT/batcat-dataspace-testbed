/*
 *  Copyright (c) 2022 Fraunhofer-Gesellschaft zur Förderung der angewandten Forschung e.V.
 *  Copyright (c) 2025 IndiScale GmbH
 *
 *  This program and the accompanying materials are made available under the
 *  terms of the Apache License, Version 2.0 which is available at
 *  https://www.apache.org/licenses/LICENSE-2.0
 *
 *  SPDX-License-Identifier: Apache-2.0
 *
 *  Contributors:
 *       Fraunhofer-Gesellschaft zur Förderung der angewandten Forschung e.V. - initial API and implementation
 *       IndiScale GmbH - add dockerize task
 *
 */

import com.bmuschko.gradle.docker.tasks.image.DockerBuildImage
import com.github.jengelman.gradle.plugins.shadow.ShadowJavaPlugin

plugins {
    `java-library`
    id("com.bmuschko.docker-remote-api") version "9.4.0"
    id("com.github.johnrengelman.shadow") version "8.1.1"
}

repositories {
    mavenCentral()
}

buildscript {
    dependencies {
        classpath(libs.edc.build.plugin)
        val edcGradlePluginsVersion: String by project
        classpath("org.eclipse.edc.edc-build:org.eclipse.edc.edc-build.gradle.plugin:${edcGradlePluginsVersion}")
    }
}

val edcVersion = libs.versions.edc
val edcGradlePluginsVersion: String by project

allprojects {
    apply(plugin = "$group.edc-build")
    version = "${edcVersion.get()}"

    // configure which version of the annotation processor to use. defaults to the same version as the plugin
    configure<org.eclipse.edc.plugins.autodoc.AutodocExtension> {
        outputDirectory.set(project.layout.buildDirectory.asFile)
        processorVersion.set(edcGradlePluginsVersion)
    }

    configure<org.eclipse.edc.plugins.edcbuild.extensions.BuildExtension> {
        publish.set(false)
    }

    configure<CheckstyleExtension> {
        configFile = rootProject.file("resources/edc-checkstyle-config.xml")
        configDirectory.set(rootProject.file("resources"))
    }

    tasks.test {
        testLogging {
            showStandardStreams = true
        }
    }

}

/** dockerize task */
subprojects {
    afterEvaluate {
        if (project.plugins.hasPlugin("com.github.johnrengelman.shadow") &&
                file("${project.projectDir}/src/main/docker/Dockerfile").exists()
        ) {

            apply(plugin = "com.bmuschko.docker-remote-api")
            val dockerTask: DockerBuildImage = tasks.create("dockerize", DockerBuildImage::class) {
                val dockerContextDir = project.projectDir
                dockerFile.set(file("$dockerContextDir/src/main/docker/Dockerfile"))
                images.add("${project.name}:${project.version}")
                images.add("${project.name}:latest")
                if (System.getProperty("platform") != null)
                    platform.set(System.getProperty("platform"))
                buildArgs.put("JAR", "build/libs/${project.name}.jar")
                inputDir.set(file(dockerContextDir))
            }
            dockerTask.dependsOn(tasks.named(ShadowJavaPlugin.SHADOW_JAR_TASK_NAME))
        }
    }
}

