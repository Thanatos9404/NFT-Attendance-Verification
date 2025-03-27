module MyModule::AttendanceNFT {
    use std::signer;
    use std::string::String;
    use std::vector;

    /// Struct representing an attendance NFT
    struct AttendanceNFT has key, store {
        event_name: String,
        participant: address,
        sequence_number: u64
    }

    /// Struct to track attendance events
    struct AttendanceEvent has key {
        event_name: String,
        total_attendees: u64
    }

    /// Create a new attendance event
    public fun create_attendance_event(
        creator: &signer, 
        event_name: String
    ) {
        let event = AttendanceEvent {
            event_name,
            total_attendees: 0
        };
        move_to(creator, event);
    }

    /// Mint an attendance NFT for a participant
    public fun mint_attendance_nft(
        creator: &signer, 
        participant: &signer, 
        event_name: String
    ) acquires AttendanceEvent {
        let creator_addr = signer::address_of(creator);
        let participant_addr = signer::address_of(participant);

        // Borrow the attendance event
        let event = borrow_global_mut<AttendanceEvent>(creator_addr);

        // Get sequence number as a unique identifier
        let sequence_number = event.total_attendees + 1;

        // Create attendance NFT
        let nft = AttendanceNFT {
            event_name,
            participant: participant_addr,
            sequence_number
        };

        // Move NFT to participant
        move_to(participant, nft);

        // Increment total attendees
        event.total_attendees = sequence_number;
    }

    /// Get total number of attendees for an event
    public fun get_total_attendees(event_creator: address): u64 acquires AttendanceEvent {
        borrow_global<AttendanceEvent>(event_creator).total_attendees
    }
}