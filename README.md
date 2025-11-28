# SQLiteVec.swift

Swift Package qui intègre SQLite avec l'extension [sqlite-vec](https://github.com/asg017/sqlite-vec) pour la recherche vectorielle performante. Compatible avec iOS et macOS, conçu pour fonctionner avec [SQLite.swift](https://github.com/stephencelis/SQLite.swift).

## Cas d'usage

- Recherche d'images similaires avec Vision.framework
- RAG (Retrieval-Augmented Generation) pour LLMs
- Recommandations basées sur les embeddings
- Recherche sémantique
- Classification par similarité

## Installation

### Swift Package Manager

Ajoutez à votre `Package.swift` :

```swift
dependencies: [
    .package(url: "https://github.com/VOTRE_USERNAME/SQLiteVec.git", from: "1.0.0")
]
```

Ou dans Xcode : File > Add Package Dependencies > entrez l'URL du repo.

## Quick Start

```swift
import SQLiteVec

// Créer une connexion avec sqlite-vec
let db = try Connection(path: "database.db")

let embeddings = VirtualTable("pokemons_embeddings")
let pokemon_id = Expression<Int64>("pokemon_id")
let set_id = Expression<String>("set_id")
let rarity = Expression<String>("rarity")
let name = Expression<String>("name")
let content_embedding = Expression<[Float]>("content_embedding")
let config = Vec0Config()
    .column(pokemon_id, primaryKey: true)
    .vector(content_embedding, dimensions: 768, distance_metric: .cosine)
    .partition(set_id)
    .metadata(rarity)   // Only TEXT, INTEGER, FLOAT and BOOLEAN (Don't support UNIQUE or NOT NULL)
    .auxiliary(name)

try db.run(embeddings.create(ifNotExists: true, .Vec0(config)))
// CREATE VIRTUAL TABLE IF NOT EXISTS "pokemons_embeddings" USING Vec0(
//      pokemon_id integer primary key,
//      content_embedding float[768] distance_metric=cosine,
//      set_id text partition key,
//      rarity text,
//      +name text
// )

// Insérer un vecteur
let embedding: [Float] = [/* 768 floats */]
try db.run(embeddings.insert(
    pokemon_id <- 345233,
    set_id <- "sv4",
    rarity <- "Common",
    name <- "Pikachu",
    content_embedding <- embedding
))

// Rechercher les plus proches
let query: [Float] = [/* 768 floats */]

let results = embeddings
    .searchNearest(pokemon_id, set_id, rarity, name, content_embedding)
    .filter(content_embedding.match(query))
    .limit(10)
// SELECT pokemon_id, set_id, rarity, name, content_embedding
// FROM "pokemons_embeddings"
// WHERE "content_embedding" MATCH ?
// LIMIT 10

for row in results {
    print("ID: \(row[pokemon_id]), Distance: \(row["distance"])")
}
```

### Normalisation des vecteurs

```swift
let embedding: [Float] = [3, 4, 0]
let normalized = embedding.normalized()
// [0.6, 0.8, 0.0]
```

## Métriques de distance

SQLiteVec supporte trois métriques :

- **`.cosine`** (recommandé) : Mesure l'angle entre vecteurs, idéal pour les embeddings ML
- **`.l2`** : Distance euclidienne, sensible à la magnitude
- **`.l1`** : Distance Manhattan, plus rapide mais moins précise

## Build depuis les sources

### Prérequis

Le script `deps.sh` permet de récupérer les sources sqlite-vec nécessaires :

```bash
./deps.sh
```

### Build

```bash
swift build
swift test
```

## Dépannage

### Performance lente

- Utilisez des transactions pour les insertions multiples
- Activez le mode WAL : `PRAGMA journal_mode = WAL`
- Augmentez le cache : `PRAGMA cache_size = -64000`
- Normalisez vos vecteurs pour `.cosine`

## Documentation

Consultez les tests pour plus d'exemples : `Tests/SQLiteVecTests/SQLiteVecTests.swift`

## Licence

Ce package est sous licence MIT. SQLite et sqlite-vec ont leurs propres licences (voir leurs repos respectifs).

## Remerciements

- [sqlite-vec](https://github.com/asg017/sqlite-vec) par Alex Garcia
- [SQLite.swift](https://github.com/stephencelis/SQLite.swift) par Stephen Celis
- [SQLite](https://www.sqlite.org/) par D. Richard Hipp
