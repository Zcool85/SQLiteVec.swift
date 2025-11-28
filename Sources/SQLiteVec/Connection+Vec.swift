//
//  Connection+Vec.swift
//  SQLiteVec
//
//  Created by Zéro Cool on 28/11/2025.
//

import Foundation
import SQLite
import CSQLiteVec

// MARK: - Extension principale de Connection

public extension Connection {
    
    /// Initialise sqlite-vec sur cette connexion
    /// Cette méthode doit être appelée une seule fois après la création de la connexion
    func enableVec() throws {
        let result = sqlite3_vec_init(self.handle, nil, nil)
        
        guard result == SQLITE_OK else {
            throw VecError.initializationFailed(
                code: result,
                message: String(cString: sqlite3_errmsg(self.handle))
            )
        }
    }
    
    /// Crée une connexion avec sqlite-vec déjà activé
    /// - Parameter location: Emplacement de la base (.inMemory, .uri, .temporary)
    /// - Returns: Connection avec vec activé
    static func vec(_ location: Location = .inMemory) throws -> Connection {
        let connection = try Connection(location)
        try connection.enableVec()
        return connection
    }
    
    /// Crée une connexion avec sqlite-vec déjà activé
    /// - Parameter path: Chemin vers le fichier de base de données
    /// - Returns: Connection avec vec activé
    static func vec(_ path: String) throws -> Connection {
        let connection = try Connection(path)
        try connection.enableVec()
        return connection
    }
    
    /// Vérifie si sqlite-vec est disponible
    var isVecEnabled: Bool {
        do {
            _ = try scalar("SELECT vec_version()") as? String
            return true
        } catch {
            return false
        }
    }
    
    /// Retourne la version de sqlite-vec
    var vecVersion: String? {
        try? scalar("SELECT vec_version()") as? String
    }
}

// MARK: - Types d'erreurs

public enum VecError: Error, LocalizedError {
    case initializationFailed(code: Int32, message: String)
    
    public var errorDescription: String? {
        switch self {
        case .initializationFailed(let code, let message):
            return "Failed to initialize sqlite-vec (code \(code)): \(message)"
        }
    }
}
