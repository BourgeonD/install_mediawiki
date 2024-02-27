# Installateur semi-automatique de MediaWiki

Ce script d'installation semi-automatique vous permettra de déployer facilement un serveur MediaWiki sur votre système. Il simplifie le processus d'installation en automatisant les tâches répétitives et en vous guidant à travers les étapes nécessaires.

## Prérequis

Avant d'exécuter ce script, assurez-vous que votre système répond aux exigences suivantes :

- **Système d'exploitation**: Linux (Ubuntu, Debian, CentOS, etc.) recommandé.
- **Accès root**: Vous aurez besoin de droits d'administration pour installer les dépendances et configurer le serveur.
- **Connexion Internet**: Assurez-vous d'avoir une connexion Internet active pour télécharger les packages requis.

## Instructions d'utilisation

1. **Téléchargement du script**: Téléchargez le script `install_mediawiki.sh` depuis le référentiel Git.

   ```bash
   wget https://example.com/install_mediawiki.sh
   ```
2. **Attribution des permissions d'exécution**: Rendez le script exécutable
   ```bash
   chmod +x install_mediawiki.sh
   ```
3. **Exécution du script**: Lancer le script en tant qu'administrateur
   ```bash
   sudo ./install_mediawiki
   ```
4. **Suivez les instructions**: Le script vous guidera à travers le processus d'installation. Vous devrez fournir des informations telles que le nom de la base de données, le nom d'utilisateur et le mot de passe.
5. **Accès à MediaWiki**: Une fois l'installation terminée, accédez à votre navigateur et ouvrez l'URL de votre serveur pour accéder à l'interface MediaWiki fraîchement installée.

## Fonctionnalités du script
 - Télécharge et installe automatiquement les packages nécessaires.
 - Configure le serveur web (Apache) pour servir MediaWiki.
 - Crée une base de données et un utilisateur MySQL/MariaDB pour MediaWiki.
 - Guide l'utilisateur à travers le processus d'installation de MediaWiki.

## Avertissement
Ce script est fourni tel quel, sans aucune garantie expresse ou implicite. Assurez-vous de comprendre ce que fait le script avant de l'exécuter sur votre système. Il est recommandé de le tester dans un environnement de test avant de l'utiliser en production.
