# ---------- Étape 1 : compilation (JDK + Maven, jetée ensuite) ----------
FROM maven:3.9-eclipse-temurin-17 AS build
WORKDIR /src
# Dépendances d'abord : couche en cache tant que pom.xml ne change pas
COPY pom.xml .
RUN mvn -B -q dependency:go-offline
# Code ensuite : ce qui change souvent est copié en dernier
COPY src ./src
RUN mvn -B -q package -DskipTests

# ---------- Étape 2 : exécution (JRE seul, utilisateur non-root appuser) ----------
FROM eclipse-temurin:17-jre-alpine
WORKDIR /app
RUN addgroup -S app && adduser -S -G app appuser
COPY --from=build --chown=appuser:app /src/target/*.jar app.jar
USER appuser

ENV SPRING_PROFILES_ACTIVE=prod
EXPOSE 2525

HEALTHCHECK --interval=10s --timeout=3s --start-period=60s --retries=5 \
  CMD wget -qO- http://127.0.0.1:2525/health > /dev/null || exit 1

ENTRYPOINT ["java", "-jar", "/app/app.jar"]
