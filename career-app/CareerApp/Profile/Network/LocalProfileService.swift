//
//  LocalProfileService.swift
//  career-app
//

import CoreData

struct LocalProfileData: Equatable {
    var name = ""
    var experience = ""
    var institution = ""
    var githubLink = ""
    var portfolioLink = ""
    var imageData: Data?
}

enum LocalProfileError: Error {
    case entityNotFound
}

protocol LocalProfileServiceProtocol {
    func loadProfile() -> LocalProfileData?
    func saveProfile(_ data: LocalProfileData) throws
    func deleteProfileImage() throws
    func deleteProfile() throws
}

/// Isola o acesso ao Core Data local de perfil (nome, experiência,
/// instituição, links, foto) — antes feito direto na ProfileView via
/// @FetchRequest/NSEntityDescription. Usa o mesmo NSManagedObjectContext
/// que a View já recebia via @Environment(\.managedObjectContext)
/// (que, na prática, é sempre PersistenceController.shared — há um
/// único contexto no app).
final class LocalProfileService: LocalProfileServiceProtocol {
    private let context: NSManagedObjectContext

    init(
        context: NSManagedObjectContext =
            PersistenceController.shared.container.viewContext
    ) {
        self.context = context
    }

    private func fetchExisting() -> UserProfile? {
        let request = NSFetchRequest<UserProfile>(
            entityName: "UserProfile"
        )
        request.fetchLimit = 1

        return try? context.fetch(request).first
    }

    func loadProfile() -> LocalProfileData? {
        guard let profile = fetchExisting() else {
            return nil
        }

        return LocalProfileData(
            name: profile.name ?? "",
            experience: profile.experience ?? "",
            institution: profile.institution ?? "",
            githubLink: profile.githubLink ?? "",
            portfolioLink: profile.portfolioLink ?? "",
            imageData: profile.profileImage
        )
    }

    func saveProfile(_ data: LocalProfileData) throws {
        let profile: UserProfile

        if let existing = fetchExisting() {
            profile = existing
        } else {
            guard let entity = NSEntityDescription.entity(
                forEntityName: "UserProfile",
                in: context
            ) else {
                throw LocalProfileError.entityNotFound
            }

            profile = UserProfile(entity: entity, insertInto: context)
            profile.id = UUID()
        }

        profile.name = data.name.isEmpty ? nil : data.name
        profile.experience = data.experience.isEmpty ? nil : data.experience
        profile.institution = data.institution.isEmpty ? nil : data.institution
        profile.githubLink = data.githubLink.isEmpty ? nil : data.githubLink
        profile.portfolioLink = data.portfolioLink.isEmpty ? nil : data.portfolioLink
        profile.profileImage = data.imageData

        try context.save()
    }

    func deleteProfileImage() throws {
        guard let profile = fetchExisting() else {
            return
        }

        profile.profileImage = nil
        try context.save()
    }

    func deleteProfile() throws {
        guard let profile = fetchExisting() else {
            return
        }

        context.delete(profile)
        try context.save()
    }
}
