package billiongoods.server.warehouse.impl;

import billiongoods.server.warehouse.*;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.test.context.ContextConfiguration;
import org.springframework.test.context.junit4.SpringJUnit4ClassRunner;
import org.springframework.transaction.annotation.Transactional;

import static org.easymock.EasyMock.*;
import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertNull;

/**
 * @author Sergey Klimenko (smklimenko@gmail.com)
 */
@Transactional
@RunWith(SpringJUnit4ClassRunner.class)
@ContextConfiguration(locations = {
		"classpath:/config/properties-config.xml",
		"classpath:/config/database-config.xml",
		"classpath:/config/personality-config.xml",
		"classpath:/config/billiongoods-config.xml"
})
public class HibernateRelationshipManagerTest {
	@Autowired
	private ArticleManager articleManager;

	@Autowired
	private RelationshipManager relationshipManager;

	public HibernateRelationshipManagerTest() {
	}

	@Test
	public void test() {
		final Category category = createMock(Category.class);
		expect(category.getId()).andReturn(13).anyTimes();
		replay(category);

		final Group group = relationshipManager.createGroup("Mock group");

		final Article a1 = articleManager.createArticle("Mock art1", "desc", category, 12.d, null, 1.2, null, null, null, null, null, null, null, null, 124.d, null);
		final Article a2 = articleManager.createArticle("Mock art2", "desc", category, 12.d, null, 1.2, null, null, null, null, null, null, null, null, 124.d, null);

		relationshipManager.addGroupItem(group.getId(), a1.getId());
		relationshipManager.addGroupItem(group.getId(), a2.getId());

		assertEquals(1, relationshipManager.getGroups(a1.getId()).size());
		assertEquals(1, relationshipManager.getGroups(a2.getId()).size());

		relationshipManager.changeRelationship(a1.getId(), RelationshipType.MODE, group.getId());

		final Relationships relationships = relationshipManager.getRelationships(a1);
		assertNull(relationships.getAssociations(RelationshipType.ACCESSORIES));
		assertEquals(2, relationships.getAssociations(RelationshipType.MODE).size());


		relationshipManager.deleteGroup(group.getId());
	}
}
