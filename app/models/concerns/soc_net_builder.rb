class SocNetBuilder

  attr_reader :word_ids, :word_ids_to_friend_ids, :word_ids_to_soc_ids

  def initialize
    @word_ids = []
    @word_ids_to_friend_ids = {}
    @word_ids_to_soc_ids = {}
  end

  def run
    SocialNode.delete_all
    cache_words_and_friends
    start_connecting_and_jumping
    collect_soc_net_per_word
  end

  def cache_words_and_friends
    Rails.logger.debug "#{self.class.name}##{__method__}"
    WordFriend.select(:word_from_id, :word_to_id).order(:word_from_id, :word_to_id).all.each do |word_friend|
      cache_word_friends(word_friend)
    end
    @word_ids = @word_ids_to_friend_ids.keys
  end

  def cache_word_friends(word_friend)
    word_from_id = word_friend.word_from_id
    word_to_id = word_friend.word_to_id
    @word_ids_to_friend_ids[word_from_id] ||= []
    @word_ids_to_friend_ids[word_from_id] << word_to_id
  end

  def start_connecting_and_jumping
    word_ids.each do |orig_id|
      connect_set(orig_id, orig_id, @word_ids_to_friend_ids[orig_id], 1)
      jump_to_set(orig_id, orig_id, @word_ids_to_friend_ids[orig_id], 1)
    end
  end

  def collect_soc_net_per_word
    word_ids.each do |orig_id|
      cache_soc_net(orig_id)
    end
    collect_soc_net
  end

  def cache_soc_net(orig_id)
    soc_net_ids = SocialNode.where(word_orig_id: orig_id).select(:word_to_id).distinct.pluck(:word_to_id)
    # @word_ids_to_soc_ids[orig_id] ||= []
    @word_ids_to_soc_ids[orig_id] = soc_net_ids
  end

  def collect_soc_net
    word_ids.each do |orig_id|
      # word = Word.find(orig_id)
      word = Word.where(id: orig_id).first
      soc_net = word_ids_to_soc_ids[word.id]
      unless soc_net.blank?
        word.traversed_ids = soc_net
        word.soc_net_size = soc_net.length
        word.save
      end
    end
  end

  def connect_set(orig_id, from_id, to_ids, step)
    Rails.logger.debug "#{self.class.name}##{__method__} -> orig_id: #{orig_id}, from_id: #{from_id}, to_ids: #{to_ids}, step: #{step}"
    unless to_ids.blank?
      allowed_to_ids = to_ids - [orig_id]
      SocialNode.bulk_insert do |worker|
        allowed_to_ids.each do |to_id|
          worker.add(word_orig_id: orig_id, word_from_id: from_id, word_to_id: to_id, qty_steps: step)
          # worker.add(word_orig_id: orig_id, word_from_id: to_id, word_to_id: from_id, qty_steps: step)
        end
      end
    end
  end

  def jump_to_set(orig_id, from_id, to_ids, step)
    Rails.logger.debug "#{self.class.name}##{__method__} -> orig_id: #{orig_id}, from_id: #{from_id}, to_ids: #{to_ids}, step: #{step}"
    unless to_ids.blank?
      allowed_to_ids = to_ids - [orig_id]
      allowed_to_ids.each do |next_from_id|
        next_to_ids = @word_ids_to_friend_ids[next_from_id]
        unless next_to_ids.blank?
          been_to_ids = SocialNode.where(word_orig_id: orig_id, word_to_id: next_to_ids).select(:word_to_id).pluck(:word_to_id)
          been_from_to_ids = SocialNode.where(word_orig_id: orig_id, word_from_id: next_from_id, word_to_id: next_to_ids).select(:word_to_id).pluck(:word_to_id)

          not_yet_connected_to_ids = next_to_ids - been_from_to_ids
          not_yet_jumped_to_to_ids = next_to_ids - been_to_ids

          Rails.logger.debug "#{self.class.name}##{__method__} -> .. next_to_ids: #{next_to_ids}"
          Rails.logger.debug "#{self.class.name}##{__method__} -> .. .. been_to_ids: #{been_to_ids}"
          Rails.logger.debug "#{self.class.name}##{__method__} -> .. .. been_from_to_ids: #{been_from_to_ids}"
          Rails.logger.debug "#{self.class.name}##{__method__} -> .. .. not_yet_connected_to_ids: #{not_yet_connected_to_ids}"
          Rails.logger.debug "#{self.class.name}##{__method__} -> .. .. not_yet_jumped_to_to_ids: #{not_yet_jumped_to_to_ids}"

          connect_set(orig_id, next_from_id, not_yet_connected_to_ids, step + 1)
          jump_to_set(orig_id, next_from_id, not_yet_jumped_to_to_ids, step + 1)
        end
      end
    end
  end
end