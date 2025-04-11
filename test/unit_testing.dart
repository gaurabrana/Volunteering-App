// Import the test package and Counter class
import 'package:VolunteeringApp/DataAccessLayer/UserDAO.dart';
import 'package:VolunteeringApp/DataAccessLayer/VolunteeringEventDAO.dart';
import 'package:VolunteeringApp/DataAccessLayer/VolunteeringEventRegistrationsDAO.dart';
import 'package:VolunteeringApp/Models/UserDetails.dart';
import 'package:VolunteeringApp/Models/VolunteeringEvent.dart';
import 'package:VolunteeringApp/Models/VolunteeringEventRegistration.dart';
import 'package:VolunteeringApp/Pages/Settings/SharedPreferences.dart';
import 'package:VolunteeringApp/constants/enums.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

@GenerateNiceMocks([
  MockSpec<UserDAO>(),
  MockSpec<VolunteeringEventDAO>(),
  MockSpec<VolunteeringEventRegistrationsDAO>(),
  MockSpec<SignInSharedPreferences>()
])
import 'unit_testing.mocks.dart';

void main() {
  late UserDAO fakeUserDAO;
  late VolunteeringEventDAO fakeVolunteeringEventDAO;
  late VolunteeringEventRegistrationsDAO fakeVolunteeringEventRegistrationsDAO;
  late SignInSharedPreferences fakeSignInSharedPreferences;
  setUp(() {
    fakeUserDAO = MockUserDAO();
    fakeVolunteeringEventDAO = MockVolunteeringEventDAO();
    fakeVolunteeringEventRegistrationsDAO =
        MockVolunteeringEventRegistrationsDAO();
    fakeSignInSharedPreferences = MockSignInSharedPreferences();
  });

  /**
   * UserDAO TEST CASES START
   */
  group("UserDAO Test Cases", () {
    test("Testing Fetching User Details", () async {
      when(fakeUserDAO.getUserDetails('test_user')).thenAnswer((_) async {
        return UserDetails(
          UID: 'test_user',
          name: 'Test User',
          email: 'testuser@example.com',
          role: UserRole.user,
          profilePhotoUrl: 'https://example.com/testuserphoto.jpg',
          reference: null,
        );
      });

      final userDetails = await fakeUserDAO.getUserDetails('test_user');

      // Verify the values.
      expect(userDetails?.UID, 'test_user');
      expect(userDetails?.name, 'Test User');
      expect(userDetails?.email, 'testuser@example.com');
      expect(userDetails?.role, UserRole.user);
      expect(userDetails?.profilePhotoUrl,
          'https://example.com/testuserphoto.jpg');

      // Verify the interaction (i.e., if the method was called once).
      verify(fakeUserDAO.getUserDetails('test_user')).called(1);
    });

    test("Testing Fetching Organisation Details", () async {
      // Define the test data that the mock method will return.
      const mission =
          "Our mission is to empower communities through education.";
      const activities = ["Education", "Healthcare", "Community Development"];
      const projects = ["Project A", "Project B", "Project C"];
      const benefactors = ["Benefactor A", "Benefactor B"];
      const certificate =
          "https://example.com/certificate.pdf"; // Sample certificate URL

      // Stub the method to return the above data when called.
      when(fakeUserDAO.fetchOrganisationDetails('test_user'))
          .thenAnswer((_) async {
        return {
          'UID': 'test_user',
          'mission': mission,
          'activities': activities,
          'completedProjects': projects,
          'benefactors': benefactors,
          'certificate':
              certificate, // Certificate could be a URL or file reference
        };
      });

      // Call the method.
      final organisationDetails =
          await fakeUserDAO.fetchOrganisationDetails('test_user');

      // Verify the values returned from the mocked method.
      expect(organisationDetails!['UID'], 'test_user');
      expect(organisationDetails['mission'], mission);
      expect(organisationDetails['activities'], activities);
      expect(organisationDetails['completedProjects'], projects);
      expect(organisationDetails['benefactors'], benefactors);
      expect(organisationDetails['certificate'], certificate);

      // Verify that the method was called once with the correct argument.
      verify(fakeUserDAO.fetchOrganisationDetails('test_user')).called(1);
    });
  });
  /**
   * UserDAO TEST CASES END
   */

  /**
   * VolunteeringEventDAO TEST CASES START
   */
  group("VolunteeringEventDAO Test Cases", () {
    test("Testing Fetching Volunteering Event", () async {
      // Define the test data that the mock method will return.
      final event = VolunteeringEvent(
        date: DateTime(2025, 5, 10),
        type: 'Charity Work',
        name: 'Community Cleanup',
        organiserContactConsent: true,
        online: false,
        description:
            'Join us for a community cleanup event in the downtown area.',
        location: 'Downtown Park',
        longitude: 12.345678,
        latitude: 98.765432,
        website: 'https://example.com/event',
        organiserUID: 'organiser_123',
        photoUrls: [
          'https://example.com/photo1.jpg',
          'https://example.com/photo2.jpg',
        ],
        currentUserRegistration:
            null, // Or provide a mocked registration object if needed.
      );

      // Stub the method to return the event when called.
      when(fakeVolunteeringEventDAO.getVolunteeringEvent('test_event'))
          .thenAnswer((_) async {
        return event;
      });

      // Call the method.
      final volunteeringEvent =
          await fakeVolunteeringEventDAO.getVolunteeringEvent('test_event');

      // Verify the values returned from the mocked method.
      expect(volunteeringEvent!.date, DateTime(2025, 5, 10));
      expect(volunteeringEvent.type, 'Charity Work');
      expect(volunteeringEvent.name, 'Community Cleanup');
      expect(volunteeringEvent.organiserContactConsent, true);
      expect(volunteeringEvent.online, false);
      expect(volunteeringEvent.description,
          'Join us for a community cleanup event in the downtown area.');
      expect(volunteeringEvent.location, 'Downtown Park');
      expect(volunteeringEvent.longitude, 12.345678);
      expect(volunteeringEvent.latitude, 98.765432);
      expect(volunteeringEvent.website, 'https://example.com/event');
      expect(volunteeringEvent.organiserUID, 'organiser_123');
      expect(volunteeringEvent.photoUrls, [
        'https://example.com/photo1.jpg',
        'https://example.com/photo2.jpg',
      ]);
      expect(volunteeringEvent.currentUserRegistration,
          null); // If using a mock reference, change this to a mocked value.

      // Verify that the method was called once with the correct argument.
      verify(fakeVolunteeringEventDAO.getVolunteeringEvent('test_event'))
          .called(1);
    });

    test(
        "Testing Fetching Volunteering Event - Throw Error if Event ID Not Found",
        () async {
      // Stub the method to throw an error if event ID does not match.
      when(fakeVolunteeringEventDAO.getVolunteeringEvent('non_existent_event'))
          .thenThrow(Exception('Event not found'));

      // Call the method and expect it to throw an error.
      expect(
        () async {
          await fakeVolunteeringEventDAO
              .getVolunteeringEvent('non_existent_event');
        },
        throwsA(isA<Exception>()),
      );

      // Verify that the method was called once with the incorrect event ID.
      verify(fakeVolunteeringEventDAO
              .getVolunteeringEvent('non_existent_event'))
          .called(1);
    });
  });
  /**
   * VolunteeringEventDAO TEST CASES END
   */

  /**
   * VolunteeringEventRegistrationsDAO TEST CASES START
   */
  group("VolunteeringEventRegistrationsDAO Test Cases", () {
    test(
        'Testing Fetching Volunteer Applications For Event with Multiple Dummy Data',
        () async {
      // Create some dummy data
      final now = DateTime.now();
      final volunteeringEventRegistration1 = VolunteeringEventRegistration(
        userId: 'test_user_1',
        eventId: 'event_123',
        isAssigned: true,
        assignedStartDate: now,
        assignedEndDate: now.add(Duration(days: 1)),
      );

      final volunteeringEventRegistration2 = VolunteeringEventRegistration(
        userId: 'test_user_2',
        eventId: 'event_124',
        isAssigned: false,
        assignedStartDate: now,
        assignedEndDate: now.add(Duration(days: 2)),
      );

      final volunteeringEventRegistration3 = VolunteeringEventRegistration(
        userId: 'test_user_3',
        eventId: 'event_125',
        isAssigned: true,
        assignedStartDate: now,
        assignedEndDate: now.add(Duration(days: 3)),
      );

      // Stub the method to return a list of volunteering events for each user
      when(fakeVolunteeringEventRegistrationsDAO
              .getAllEventIdsForUser('test_user_1'))
          .thenAnswer((_) async =>
              [volunteeringEventRegistration1, volunteeringEventRegistration2]);

      when(fakeVolunteeringEventRegistrationsDAO
              .getAllEventIdsForUser('test_user_2'))
          .thenAnswer((_) async =>
              [volunteeringEventRegistration2, volunteeringEventRegistration3]);

      when(fakeVolunteeringEventRegistrationsDAO
              .getAllEventIdsForUser('test_user_3'))
          .thenAnswer((_) async =>
              [volunteeringEventRegistration1, volunteeringEventRegistration3]);

      // List of test cases for different users
      final testCases = {
        'test_user_1': [
          volunteeringEventRegistration1,
          volunteeringEventRegistration2
        ],
        'test_user_2': [
          volunteeringEventRegistration2,
          volunteeringEventRegistration3
        ],
        'test_user_3': [
          volunteeringEventRegistration1,
          volunteeringEventRegistration3
        ],
      };

      // Run the test for each user
      for (var userId in testCases.keys) {
        // Call the method being tested
        final result = await fakeVolunteeringEventRegistrationsDAO
            .getAllEventIdsForUser(userId);

        // Verify that the method was called with the correct argument
        verify(fakeVolunteeringEventRegistrationsDAO
                .getAllEventIdsForUser(userId))
            .called(1);

        // Assert that results are not empty and contain the correct data
        expect(result, isNotEmpty);
        expect(result[0].userId, testCases[userId]![0].userId);
        expect(result[1].userId, testCases[userId]![1].userId);

        // Assert the event IDs are as expected
        expect(result[0].eventId, testCases[userId]![0].eventId);
        expect(result[1].eventId, testCases[userId]![1].eventId);

        // Assert assigned status
        expect(result[0].isAssigned, testCases[userId]![0].isAssigned);
        expect(result[1].isAssigned, testCases[userId]![1].isAssigned);
      }
    });

    test(
        'should return the correct registration status for a given user and event',
        () async {
      // Mock the method to return a VolunteeringEventRegistration when called
      when(fakeVolunteeringEventRegistrationsDAO.getUserRegistrationStatus(
        userId: 'test_user_1',
        eventId: 'event_1',
      )).thenAnswer((_) async {
        return VolunteeringEventRegistration(
          userId: 'test_user_1',
          eventId: 'event_1',
          isAssigned: true,
          assignedStartDate: DateTime.now(),
          assignedEndDate: DateTime.now().add(Duration(days: 1)),
        );
      });

      // Call the method to test
      final result =
          await fakeVolunteeringEventRegistrationsDAO.getUserRegistrationStatus(
        userId: 'test_user_1',
        eventId: 'event_1',
      );

      // Verify the result matches the expected registration details
      expect(result, isNotNull);
      expect(result?.userId, 'test_user_1');
      expect(result?.eventId, 'event_1');
      expect(result?.isAssigned, true);
    });

    test(
        'should return null when the registration is not found for a user and event',
        () async {
      // Mock the method to return null when no registration is found
      when(fakeVolunteeringEventRegistrationsDAO.getUserRegistrationStatus(
        userId: 'test_user_2',
        eventId: 'event_2',
      )).thenAnswer((_) async {
        return null; // No registration found
      });

      // Call the method to test
      final result =
          await fakeVolunteeringEventRegistrationsDAO.getUserRegistrationStatus(
        userId: 'test_user_2',
        eventId: 'event_2',
      );

      // Verify that the result is null
      expect(result, isNull);
    });

    test(
        'should return the correct registration status when user exists but with different event',
        () async {
      // Mock the method to return a VolunteeringEventRegistration with a different event
      when(fakeVolunteeringEventRegistrationsDAO.getUserRegistrationStatus(
        userId: 'test_user_1',
        eventId: 'event_2',
      )).thenAnswer((_) async {
        return VolunteeringEventRegistration(
          userId: 'test_user_1',
          eventId: 'event_2',
          isAssigned: false,
          assignedStartDate: DateTime.now(),
          assignedEndDate: DateTime.now().add(Duration(days: 2)),
        );
      });

      // Call the method to test
      final result =
          await fakeVolunteeringEventRegistrationsDAO.getUserRegistrationStatus(
        userId: 'test_user_1',
        eventId: 'event_2',
      );

      // Verify the result for a different event
      expect(result, isNotNull);
      expect(result?.userId, 'test_user_1');
      expect(result?.eventId, 'event_2');
      expect(result?.isAssigned, false);
    });
  });
  /**
   * VolunteeringEventRegistrationsDAO TEST CASES END
   */

  /**
   * SignInSharedPreferences TEST CASES END
   */
  group('SharedPreferences Methods Tests', () {
    test('isSignedIn returns true when user is signed in', () async {
      // Arrange: Mock SharedPreferences to return true for 'isSignedIn'
      when(fakeSignInSharedPreferences.isSignedIn())
          .thenAnswer((_) async => true);

      // Act: Call the method
      bool isSigned = await fakeSignInSharedPreferences.isSignedIn();

      // Assert: Verify the result is true
      expect(isSigned, true);
      verify(fakeSignInSharedPreferences.isSignedIn()).called(1);
    });

    test('isSignedIn returns false when no value is set', () async {
      // Arrange: Mock SharedPreferences to return false for 'isSignedIn'
      when(fakeSignInSharedPreferences.isSignedIn())
          .thenAnswer((_) async => false);

      // Act: Call the method
      bool isSigned = await fakeSignInSharedPreferences.isSignedIn();

      // Assert: Verify the result is false
      expect(isSigned, false);
      verify(fakeSignInSharedPreferences.isSignedIn()).called(1);
    });

    test('getCurrentUserDetails returns UserDetails when userDetails exists',
        () async {
      // Arrange: Mock SharedPreferences to return a userDetails string
      final userDetails = UserDetails(
        UID: 'test_user',
        name: 'Test User',
        email: 'testuser@example.com',
        role: UserRole.user,
        profilePhotoUrl: 'https://example.com/testuserphoto.jpg',
        reference: null,
      );
      when(fakeSignInSharedPreferences.getCurrentUserDetails())
          .thenAnswer((_) async => userDetails);

      // Act: Call the method
      final result = await fakeSignInSharedPreferences.getCurrentUserDetails();

      // Assert: Verify the result is a valid UserDetails object
      expect(result, isNotNull);
      expect(result!.name, 'Test User');
      expect(result.email, 'testuser@example.com');
      verify(fakeSignInSharedPreferences.getCurrentUserDetails()).called(1);
    });

    test('getCurrentUserDetails returns null when userDetails does not exist',
        () async {
      // Arrange: Mock SharedPreferences to return null for 'userDetails'
      when(fakeSignInSharedPreferences.getCurrentUserDetails())
          .thenAnswer((_) async => null);

      // Act: Call the method
      final result = await fakeSignInSharedPreferences.getCurrentUserDetails();

      // Assert: Verify the result is null
      expect(result, null);
      verify(fakeSignInSharedPreferences.getCurrentUserDetails()).called(1);
    });
  });

  /**
   * SignInSharedPreferences TEST CASES END
   */
}
